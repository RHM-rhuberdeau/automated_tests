require_relative './redesign_question_page'

module RedesignQuestion
  class RedesignMobileQuestionPage < RedesignQuestionPage
    attr_reader :driver, :proxy

    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      RedesignQuestion::FunctionalityTestCases.new(:driver => @driver, 
                                                :proxy => @proxy, 
                                                :author_name => args[:author_name], 
                                                :author_role => args[:author_role],
                                                :nofollow_author_links => args[:nofollow_author_links],
                                                :profile_link => args[:profile_link])
    end
  end

  class FunctionalityTestCases
    include ::ActiveModel::Validations

    # validate :relative_header_links
    # validate :relative_right_rail_links
    # validate :has_publish_date
    # validate :author_name
    # validate :author_role
    # validate :author_links
    # validate :profile_link

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
          if link.attribute('rel') && link.attribute('rel') == 'nofollow' && (link.attribute('href').include?("/profiles/c/newsletters/subscribe") == false)
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
      
    end
  end
end