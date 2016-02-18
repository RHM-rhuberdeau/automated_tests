require_relative './redesign_entry_page'

module RedesignEntry
  class RedesignEntryMobilePage < RedesignEntryPage
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

    def analytics_file
      has_file = false
      network_traffic = get_network_traffic
      network_traffic.each do |entry|
        unless entry.empty?
          entry = entry.first
          if (entry.first.include?('namespace.js')) && (entry.last == 200)
            has_file = true
          end
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
      links = (all(:css, ".js-HC-header a").to_a + all(:css, ".HC-nav-content a").to_a + all(:css, ".Page-sub-category a").to_a).collect{|x| x[:href]}.compact
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
      wait_for { has_selector?(".MostPopular-container", :visible => true) }
      links = (all(:css, ".Node-content-secondary a").to_a + all(:css, ".MostPopular-container a").to_a).collect{|x| x[:href]}.compact
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
      publish_date = find(:css, "span.Page-info-publish-date").text
      unless publish_date
        self.errors.add(:base, "Page was missing a publish date")
      end
      unless publish_date.scan(/\w+\s\d+,\s\d+/).length == 1
        self.errors.add(:base, "Publish date was in the wrong format: #{publish_date}")
      end
    end

    def author_name
      author_name = find(:css, ".Page-info-publish-author a").text
      unless author_name
        self.errors.add(:base, "Page was missing an author name")
      end
      unless author_name == @author_name
        self.errors.add(:base, "author name was #{author_name} not #{@author_name}")
      end 
    end

    def author_role
      author_role = find(:css, "span.Page-info-publish-badge").text
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
      post_links = all(:css, "ul.ContentList.ContentList--blogpost a")
      if post_links
        post_links.each do |link|
          if link[:href] && link[:href].length > 0
            @links_in_post << link[:href]
          end
          if link[:rel] && link[:rel] == 'nofollow' && (link[:href].include?("/profiles/c/newsletters/subscribe") == false)
            @links_with_no_follow << link[:href]
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
      
    end
  end

  class AdsTestCases < HealthCentralAds::AdsTestCases
    include ::ActiveModel::Validations

    validate :pharma_safe
    validate :loads_analytics_file

    def loads_analytics_file
      unless @page.analytics_file == true
        self.errors.add(:base, "namespace.js was not loaded")
      end
    end
  end
end