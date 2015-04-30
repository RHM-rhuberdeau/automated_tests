require_relative './healthcentral_page'

module RedesignEntry
  class RedesignEntryPage < HealthCentralPage
    attr_reader :driver, :proxy

    def initialize(driver,proxy, fixture=nil)
    	@driver  = driver
      @proxy   = proxy
      @fixture = fixture
    end

    def functionality(args)
      RedesignEntry::FunctionalityTestCases.new(:driver => @driver, 
                                                :proxy => @proxy, 
                                                :author_name => args[:author_name], 
                                                :author_role => args[:author_role],
                                                :nofollow_author_links => args[:nofollow_author_links],
                                                :profile_link => args[:profile_link])
    end

    def assets
      all_images = @driver.find_elements(tag_name: 'img')
      HealthCentralAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def omniture
      @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
      omniture = HealthCentralOmniture::Omniture.new(omniture_text, @fixture)
    end

    def global_test_cases
      RedesignEntry::GlobalTestCases.new(@driver, @proxy)
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

    validate :health_logo
    validate :health_az_menu
    validate :social_icons
    validate :subcategory_navigation
    validate :footer

    # This test is useless
    # Too much content is injected by js that we can't control
    # Need to check the links in the page source, not all links on the page
    # validate :link_hostnames

    def initialize(driver, proxy)
      @driver = driver
      @proxy  = proxy
    end

    def health_logo
      logo_1 = @driver.find_element(:css, "span.LogoHC-part1")
      logo_2 = @driver.find_element(:css, "span.LogoHC-part2")

      unless (logo_1.text == "Health" && logo_2.text == "Central")
        self.errors.add(:base, "Health Logo was missing from the page")
      end

      link = @driver.find_element(:css, "a.LogoHC")
      link.click
      sleep 1
      unless @driver.current_url == "#{HC_BASE_URL}/"
        self.errors.add(:base, "The logo linked to #{@driver.current_url} not #{HC_BASE_URL}/")
      end
      @driver.navigate.back
    end

    def health_az_menu
      #Open Health A-Z Menu
      wait_for { @driver.find_element(:css, ".Button--AZ").displayed? }
      nav_on_pageload = @driver.find_elements(:css, ".HC-nav")
      if nav_on_pageload
        nav_on_pageload = nav_on_pageload.select { |x| x.displayed? }
      end

      button = @driver.find_element(:css, ".Button--AZ")
      button.click
      wait_for { @driver.find_element(:css, ".HC-nav").displayed? }
      az_nav = @driver.find_element(:css, ".HC-nav")

      unless nav_on_pageload.empty?
        self.errors.add(:base, "A-Z was on the page before clicking it")
      end
      unless az_nav
        self.errors.add(:base, "A-Z nav did not appear on the page afer clicking the Health A-Z button")
      end

      #Check for Category Links
      wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
      titles = @driver.find_elements(:css, ".js-Nav--Primary-accordion-title").select {|x| x.displayed? }.select {|x| x.text == "BODY & MIND" || x.text == "FAMILY HEALTH" || x.text == "HEALTHY LIVING"}
      unless titles.length == 3
        self.errors.add(:base, "Not all super categories were on the page. Present were: #{titles}")
      end 

      #Check for Sub Category links
      sub_category_links      = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary .Nav-listGroup-list--General  a")
      sub_category_links_text = sub_category_links.collect {|x| x.text }
      all_links_counted_for   = ::HealthCentralPage::SUB_CATEGORIES - sub_category_links_text
      extra_links             = sub_category_links_text - ::HealthCentralPage::SUB_CATEGORIES

      unless (sub_category_links.length == ::HealthCentralPage::SUB_CATEGORIES.length && all_links_counted_for.empty?)
        self.errors.add(:base, "There were missing or extra subcategory links in the health a-z menu: #{all_links_counted_for}")
      end
      unless (extra_links.empty?)
        self.errors.add(:base, "There were extra sub_category links on the page: #{extra_links}")
      end

      unless ENV['TEST_ENV'] == "stage"
        ibd = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary a").select { |x| x.text == "Digestive Health"}.first
        ibd.click
        wait_for { @driver.find_element(:css, ".Phases-navigation").displayed? }
        unless (@driver.current_url == "#{HC_BASE_URL}/ibd/" || @driver.current_url == "#{HC_BASE_URL}/ibd")
          self.errors.add(:base, "IBD linked to #{@driver.current_url} not #{HC_BASE_URL}/ibd/")
        end
        @driver.navigate.back
      end
    end

    def social_icons
      wait_for { @driver.find_element(:css, ".HC-header-content span.icon-facebook").displayed? }
      #Check Facebook icon
      fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-facebook")
      fb_icon.click
      sleep 1
      first_window  = @driver.window_handles.first
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://www.facebook.com/HealthCentral?v=app_369284823108595"
        self.errors.add(:base, "Facebook icon linked to #{@driver.current_url} not https://www.facebook.com/HealthCentral?v=app_369284823108595")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Twitter icon
      twitter_icon = @driver.find_element(:css, ".HC-header-content span.icon-twitter")
      twitter_icon.click
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://twitter.com/healthcentral"
        self.errors.add(:base, "Twitter icon linked to #{@driver.current_url} not https://twitter.com/healthcentral")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Pinterest icon
      pinterest_icon = @driver.find_element(:css, ".HC-header-content span.icon-pinterest")
      pinterest_icon.click
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://www.pinterest.com/HealthCentral/"
        self.errors.add(:base, "Pinterest icon linked to #{@driver.current_url} not https://www.pinterest.com/HealthCentral/")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Mail Icon
      mail_icon = @driver.find_element(:css, ".HC-header-content span.icon-mail")
      mail_icon.click
      sleep 1
      unless @driver.current_url == "#{HC_BASE_URL}/profiles/c/newsletters/subscribe"
        self.errors.add(:base, "Mail icon linked to  #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
      end
      begin
        menu = @driver.find_element(:css, "div.Subscriptions-main")
      rescue
        menu = nil 
      end
      if menu.nil?
        self.errors.add(:base, "Newsletter page did not load: #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
      end
      @driver.navigate.back
    end

    def subcategory_navigation
      fb_share          = @driver.find_element(:css, "span.icon-facebook.icon-light.js-social--share")
      twitter_share     = @driver.find_element(:css, "span.icon-twitter.icon-light.js-social--share")
      stumbleupon_share = @driver.find_element(:css, "span.icon-stumbleupon.icon-light.js-social--share")
      mail_share        = @driver.find_element(:css, "span.icon-mail.icon-light.js-social--share")
    end

    def footer
      footer_links = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "About Us" || x.text == "Contact Us" || x.text == "Privacy Policy" || x.text == "Terms of Use" || x.text == "Security Policy" || x.text == "Advertising Policy" || x.text == "Advertise With Us" }
      other_sites = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "The Body" || x.text == "The Body Pro" || x.text == "Berkeley Wellness" || x.text == "Health Communities" || x.text == "Health After 50" || x.text == "Intelecare" || x.text == "Mood 24/7"}
      unless footer_links.length == 7
        self.errors.add(:base, "Links missing from footer: #{footer_links}")
      end
      unless other_sites.length == 7
        self.errors.add(:base, "Missing links to other sites in the footer: #{other_sites}")
      end
    end

    def link_hostnames
      site_links = links_on_page
      bad_links = site_links_with_wrong_hostname(site_links)
      unless bad_links.compact.empty?
        self.errors.add(:base, "There are links with hard coded hostnames: #{bad_links}")
      end
    end

    def links_on_page
      all_links  = @driver.find_elements(:tag_name, "a")
      site_links = all_links.collect do |link|
        if link.attribute('href') && link.attribute('href').include?("healthcentral")
          link.attribute('href').gsub('http://', '')
        end
      end
      site_links = site_links.compact
    end

    def site_links_with_wrong_hostname(site_links)
      bad_urls = site_links.map do |link|
        if (link.index((ASSET_HOST).gsub('http://', '')) != 0) && !link.include?("twitter")
          link
        end
      end
      bad_urls.compact
    end
  end
end