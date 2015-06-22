require_relative './healthcentral_page'

module RedesignEntry
  class RedesignEntryPage < HealthCentralPage
    attr_reader :driver, :proxy

    def initialize(args)
    	@driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      RedesignEntry::FunctionalityTestCases.new(:driver => @driver, 
                                                :proxy => @proxy, 
                                                :author_name => args[:author_name], 
                                                :author_role => args[:author_role],
                                                :nofollow_author_links => args[:nofollow_author_links],
                                                :profile_link => args[:profile_link])
    end

    def global_test_cases
      RedesignEntry::GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
    end

    def analytics_file
      has_file = false
      proxy.har.entries.each do |entry|
        if entry.request.url.include?('namespace.js')
          has_file = true
        end
      end
      has_file
    end
  end

  class FunctionalityTestCases
    include ::ActiveModel::Validations

    validate :relative_header_links
    validate :relative_right_rail_links
    validate :has_publish_date
    validate :author_name
    validate :author_role
    validate :author_links
    validate :profile_link

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @author_name            = args[:author_name]
      @author_role            = args[:author_role]
      @nofollow_author_links  = args[:nofollow_author_links]
      @profile_link           = args[:profile_link]
    end
    
    def relative_header_links
      links = (@driver.find_elements(:css, ".js-HC-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
      bad_links = links.map do |link|
        if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
          link unless link.include?("twitter")
        end
      end
      unless bad_links.compact.length == 0
        self.errors.add(:base, "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end
    end 

    def relative_right_rail_links
      wait_for { @driver.find_element(:css, ".MostPopular-container").displayed? }
      links = (@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact
      bad_links = links.map do |link|
        if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
          link unless link.include?("id=promo")
        end
      end
      unless bad_links.compact.length == 0
        self.errors.add(:base, "There were links in the right rail that did not use relative paths: #{bad_links.compact}")
      end
    end

    def has_publish_date
      publish_date = @driver.find_element(:css, "span.Page-info-publish-date").text
      unless publish_date
        self.errors.add(:base, "Page was missing a publish date")
      end
      unless publish_date.scan(/\w+\s\d+,\s\d+/).length == 1
        self.errors.add(:base, "Publish date was in the wrong format: #{publish_date}")
      end
    end

    def author_name
      author_name = @driver.find_element(:css, ".Page-info-publish-author a").text
      unless author_name
        self.errors.add(:base, "Page was missing an author name")
      end
      unless author_name == @author_name
        self.errors.add(:base, "author name was #{author_name} not #{@author_name}")
      end 
    end

    def author_role
      author_role = @driver.find_element(:css, "span.Page-info-publish-badge").text
      unless author_role
        self.errors.add(:base, "Page was missing an author role")
      end
      unless author_role == @author_role
        self.errors.add(:base, "author role was #{author_role} not #{@author_role}")
      end 
    end

    def author_links
      @links_in_post = []
      @links_with_no_follow = []
      post_links = @driver.find_elements(:css, "ul.ContentList--blogpost a")
      if post_links
        post_links.each do |link|
          if link.attribute('href') && link.attribute('href').length > 0
            @links_in_post << link.attribute('href')
          end
          if link.attribute('rel') && link.attribute('rel') == 'nofollow'
            @links_with_no_follow << link.attribute('href')
          end
        end
      end

      if @nofollow_author_links == true
        if (@links_with_no_follow.compact.length != @links_in_post.compact.length) 
          self.errors.add(:base, "Community user had links without nofollow: #{@links_with_no_follow} #{@links_in_post }")
        end
      end
      if @nofollow_author_links == false
        if (@links_with_no_follow.compact.length > 0)
          self.errors.add(:base, "Expert post had links with nofollow: #{@links_with_no_follow.compact}")
        end
      end
    end

    def profile_link
      profile_img = @driver.find_element(:css, "a.Page-info-visual img")
      profile_img.click
      unless @driver.current_url == @profile_link
        self.errors.add(:base, "Profile img linked to #{@driver.current_url} not #{@profile_link}")
      end
    end
  end

  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view
    validate :correct_ad_site
    validate :correct_ad_categories
    validate :pharma_safe
    validate :loads_analytics_file

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @url                    = args[:url]
      @ad_site                = args[:ad_site]
      @expected_ad_site       = args[:expected_ad_site]
      @ad_categories          = args[:ad_categories]
      @expected_ad_categories = args[:expected_ad_categories]
      @pharma_safe            = args[:pharma_safe]
      @expected_pharma_safe   = args[:expected_pharma_safe]
    end

    def unique_ads_per_page_view
      @ads = {}
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[1] = @all_ads

      visit @url
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[2] = @all_ads - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| HealthCentralAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| HealthCentralAds::Ads.new(ad) }

      ord_values_1 = ads_from_page1.collect(&:ord).uniq
      ord_values_2 = ads_from_page2.collect(&:ord).uniq

      unless ord_values_1.length == 1
        self.errors.add(:base, "Ads on the first view had multiple ord values: #{ord_values_1}")
      end
      unless ord_values_2.length == 1
        self.errors.add(:base, "Ads on the second view had multiple ord values: #{ord_values_2}")
      end
      unless (ord_values_1[0] != ord_values_2[0])
        self.errors.add(:base, "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end
    end

    def correct_ad_site
      unless @ad_site == @expected_ad_site
        self.errors.add(:base, "ad_site was #{@ad_site} not #{@expected_ad_site}")
      end
    end

    def correct_ad_categories
      unless @ad_categories == @expected_ad_categories
        self.errors.add(:base, "ad_categories was #{@ad_categories} not #{@expected_ad_categories}")
      end
    end

    def pharma_safe
      unless @pharma_safe == @expected_pharma_safe
        self.errors.add(:base, "ad_categories was #{@pharma_safe} not #{@expected_pharma_safe}")
      end
    end 

    def loads_analytics_file
      unless @page.analytics_file == true
        self.errors.add(:base, "namespace.js was not loaded")
      end
    end
  end

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :head_navigation
    validate :footer

    def initialize(args)
      @head_navigation = args[:head_navigation]
      @footer          = args[:footer]
    end

    def head_navigation
      @head_navigation.validate
      unless @head_navigation.errors.empty?
        self.errors.add(:head_navigation, @head_navigation.errors.values.first)
      end
    end

    def footer
      @footer.validate
      unless @footer.errors.empty?
        self.errors.add(:footer, @footer.errors.values.first)
      end
    end
  end
end