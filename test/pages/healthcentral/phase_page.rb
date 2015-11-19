require_relative './healthcentral_page'

module Phases
  class PhasePage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      Functionality.new(:driver => @driver, :phase => args[:phase], :phase_navigation => args[:phase_navigation])
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :phase_navigation
    validate :current_phase_highlighted
    validate :social_controls
    validate :page_description
    validate :we_recommend
    validate :latest_posts
    validate :pagination
    validate :dig_deeper

    def initialize(args)
      @driver           = args[:driver]
      @phase            = args[:phase]
      @phase_navigation = args[:phase_navigation]
    end

    def phase_navigation
      wait_for          { @driver.find_element(:css, ".js-TrackingInternal--pha ul").displayed? }
      phase_nav_menu  = find ".js-TrackingInternal--pha ul"
      phase_nav_items = @driver.find_elements(:css, ".js-TrackingInternal--pha ul li")
      phase_nav_text  = phase_nav_items.compact.collect { |x| x.text } if phase_nav_items

      unless phase_nav_menu
        self.errors.add(:phase_navigation, "Phase Navigation menu did not appear on the page")
      end
      unless phase_nav_text == @phase_navigation
        self.errors.add(:phase_navigation, "Phase Navigation text was #{phase_nav_text} not #{@phase_navigation}")
      end
    end

    def current_phase_highlighted
      highlighted       = find ".Nav-list-item.js-nav-item.is-active"
      highlighted_phase = highlighted.text if highlighted
      unless highlighted
        self.errors.add(:current_phase_highlighted, "None of the phases in the Phase Navigation menu were highlighted")
      end
      unless highlighted_phase && highlighted_phase.downcase == @phase
        self.errors.add(:current_phase_highlighted, "#{highlighted_phase} was highlighted not #{@phase}")
      end
    end 

    def social_controls
      wait_for { @driver.find_element(:css, "div.Page-main-content div.SocialButtons--Share ul.SocialButtons-list a.js-Social--Follow-actionable-Facebook").displayed? }
      facebook      = find "div.Page-main-content div.SocialButtons--Share ul.SocialButtons-list a.js-Social--Follow-actionable-Facebook"
      twitter       = find "div.Page-main-content div.SocialButtons--Share ul.SocialButtons-list a.js-Social--Follow-actionable-Twitter"
      pinterest     = find "div.Page-main-content div.SocialButtons--Share ul.SocialButtons-list a.js-Social--Follow-actionable-Pinterest"
      stumble_upon  = find "div.Page-main-content div.SocialButtons--Share ul.SocialButtons-list a.js-Social--Follow-actionable-Stumbleupon"

      unless facebook
        self.errors.add(:social_controls, "Facebook share link did not appear on the page")
      end
      unless pinterest
        self.errors.add(:social_controls, "pinterest share link did not appear on the page")
      end
      unless twitter
        self.errors.add(:social_controls, "twitter share link did not appear on the page")
      end
      unless stumble_upon
        self.errors.add(:social_controls, "stumble_upon share link did not appear on the page")
      end
    end

    def page_description
      page_description = find "div.Taxonomy-term-description"
      description_text = page_description.text if page_description

      unless page_description
        self.errors.add(:page_description, "page description did not appear on the page")
      end
      unless description_text && description_text.length > 0
        self.errors.add(:page_description, "Page description did not have any text")
      end
    end

    def we_recommend
      we_recommend          = find ".CollectionListWeRecommend"
      we_recommend_header   = find "h4.CollectionListBoxes-titleSub"
      we_recommend_modules  = @driver.find_elements(:css, ".CollectionListWeRecommend ul.CollectionListBoxes-list li")
      we_recommend_links    = @driver.find_elements(:css, "a.CollectionListBoxes-box")
      we_recommend_titles   = @driver.find_elements(:css, ".CollectionListBoxes-box-info-title")
      we_recommend_titles   = we_recommend_titles.select { |x| x.text.length > 0 }

      unless we_recommend
        self.errors.add(:we_recommend, "We Recommend section did not appear on the page")
      end
      unless we_recommend_header
        self.errors.add(:we_recommend, "We Recommend header was missing from the page")
      end
      unless we_recommend_header.text == "WE RECOMMEND"
        self.errors.add(:we_recommend, "We Recommend header was #{we_recommend_header.text} not We Recommend")
      end
      unless we_recommend_modules && we_recommend_modules.length >= 2
        self.errors.add(:we_recommend, "3 We Recommend modules did not appear on the page")
      end
      unless we_recommend_modules.length == we_recommend_links.length
        self.errors.add(:we_recommend, "There was a We Recomend module without a link")
      end
      unless we_recommend_modules.length == we_recommend_titles.length
        self.errors.add(:we_recommend, "One of the We Recommend modules was missing a title: #{we_recommend_modules.length} #{we_recommend_titles.length}")
      end
    end

    def latest_posts
      latest_posts        = @driver.find_elements(:css, ".Editor-picks-container div.Editor-picks-item.u-pullLeft")
      latest_posts_header = find "h4.Block-title" 
      header_text         = latest_posts_header.text if latest_posts_header
      latest_posts_images = @driver.find_elements(:css, ".Editor-picks-image.u-pullLeft img")
      alt_images          = @driver.find_elements(:css, "img.Editor-picks-slide-visual-image")
      latest_posts_titles = @driver.find_elements(:css, ".Editor-picks-title-container.js-Editor-picks-title-container")
      latest_posts_titles = latest_posts_titles.select { |x| x.text.length > 0 }

      unless latest_posts.length >= 8
        self.errors.add(:latest_posts, "There were only #{latest_posts.length} modules on the page")
      end
      unless header_text == "LATEST POSTS"
        self.errors.add(:latest_posts, "LATEST POSTS did not appear on the page")
      end
      unless latest_posts.length == (latest_posts_images.length + alt_images.length)
        self.errors.add(:latest_posts, "One of the Latest Posts modules was missing an image")
      end
      latest_posts_titles.each do |post|
        if post.text == "..."
          self.errors.add(:latest_posts, "Latest Post content title using ellipses")
        end
      end
      unless latest_posts_titles.length == latest_posts.length
        self.errors.add(:latest_posts, "One of the latest posts modules was missing a title")
      end
    end

    def pagination
      pagination       = find "div.CollectionListBoxes-button"
      pagination_label = find "div.Custom-paginator-info"
      pagination_next  = find "span.Custom-paginator-controls-next-button-label"
      pagination_prev  = find ".Custom-paginator-controls-prev-icon.icon-left-open-big"
      page_total       = find ".Custom-paginator-label-pageTotal"
      if page_total
        number_of_pages = page_total.text.to_i
      end

      unless pagination
        self.errors.add(:pagination, "pagination did not appear on the page")
      end
      unless pagination_label
        self.errors.add(:pagination, "pagination label did not appear on the page")
      end
      unless pagination_next || ( !number_of_pages.nil? && number_of_pages <= 9 )
        self.errors.add(:pagination, "Next button did not appear on the page")
      end
      if pagination_prev
        self.errors.add(:pagination, "Previous button appeared on the first page")
      end

      if pagination_next
        begin
          pagination_next.click
        rescue Selenium::WebDriver::Error::TimeOutError
        end
        sleep 1 

        pagination       = find "div.CollectionListBoxes-button"
        pagination_label = find "div.Custom-paginator-info"
        pagination_next  = find ".Custom-paginator-controls-next-button"
        pagination_prev  = find ".Custom-paginator-controls-prev-icon.icon-left-open-big"
        page_total       = find ".Custom-paginator-label-pageTotal"
        if page_total
          number_of_pages = page_total.text.to_i
        end

        unless pagination
          self.errors.add(:pagination, "pagination did not appear on the second page")
        end
        unless pagination_label
          self.errors.add(:pagination, "pagination label did not appear on the second page")
        end
        unless pagination_next || ( !number_of_pages.nil? && number_of_pages <= 18 )
          self.errors.add(:pagination, "Next button did not appear on the second page")
        end
        unless pagination_prev
          self.errors.add(:pagination, "Previous button did not appear on the second page")
        end
      end
    end

    def dig_deeper
      wait_for { @driver.find_element(:css, ".TopicListInset").displayed? }
      dig_deepr_listings = @driver.find_elements(:css, "ul.TopicListInset-topiclist li")
      dig_deeper_links   = @driver.find_elements(:css, "ul.TopicListInset-topiclist li a")

      dig_deepr_listings.each do |listing|
        unless listing.text.length > 0
          self.errors.add(:dig_deeper, "One of the Dig Deeper listing was blank")
        end
      end
      unless dig_deeper_links.length == dig_deepr_listings.length
        self.errors.add(:dig_deeper, "One of the Dig Deeper listings was missing a link")
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