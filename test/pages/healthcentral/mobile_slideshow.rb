require_relative './healthcentral_page'

module HealthCentralMobileSlideshow
  class MobileSlideshowPage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def assets
      all_images = @driver.find_elements(tag_name: 'img')
      HealthCentralAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    # validate :relative_links_in_the_header
    validate :page_has_slides
    validate :more_on_this_topic
    validate :includes_publish_date
    validate :includes_updated_date
    validate :ads_are_lazy_loaded
    validate :loads_next_slideshow

    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
    end

    def page_has_slides
      slides = @driver.find_elements(:css, ".SlideList-item")
      if slides
        slides = slides.select {|s| s.displayed?}
      else
        slides = []
      end
      unless slides.length >= 1
        self.errors.add(:base, "There were only #{slides.length} slides on the page")
      end
    end

    def ads_are_lazy_loaded
      wait_for { @driver.find_elements(:css, "div.SlideList-item").first.displayed? }
      scroll_to_bottom_of_page
      sleep 1
      slides = @driver.find_elements(:css, "div.SlideList-item")
      all_ads = HealthCentralPage.get_all_ads(@proxy)
      ads = all_ads.map { |ad| HealthCentralAds::Ads.new(ad) }
      ord_values = ads.map {|x| x.ord}.compact.uniq
      unless  ord_values.length == all_ads.length
        self.errors.add(:base, "Some of the ads shared the same ord value: #{ord_values}")
      end
      unless ads.length == slides.length.div(2)
        self.errors.add(:base, "There were #{slides.length} slides and #{all_ads.length} ads")
      end
    end

    def includes_publish_date
      publish_date = @driver.find_element(:css, "span.Page-info-publish-date").text
      unless publish_date
        self.errors.add(:base, "Page was missing a publish date")
      end
      unless publish_date.scan(/\w+\s\d+,\s\d+/).length == 1
        self.errors.add(:base, "Publish date was in the wrong format: #{publish_date}")
      end
    end

    def includes_updated_date
      publish_date = @driver.find_element(:css, "span.Page-info-publish-updated").text
      unless publish_date
        self.errors.add(:base, "Page was missing a publish date")
      end
      date = publish_date.gsub("updated", '').strip if publish_date
      unless date.scan(/\w+\s\d+,\s\d+/).length == 1
        self.errors.add(:base, "Publish date was in the wrong format: #{publish_date}")
      end
    end

    def more_on_this_topic
      more_on_header = find "h2.CollectionListTopic-title"

      if @collection == true
        unless more_on_header
          self.errors.add(:base, "More on this topic did not appear on the page")
        end
        if more_on_header
          text = more_on_header.text
          unless text == "More on this topic"
            self.errors.add(:base, "More on this topic header was: #{text} not: More on this topic")
          end
        end
      end

      if @collection == false
        if more_on_header
          self.errors.add(:base, "More on this topic appeared on a noncollection slideshow")
        end
      end
    end

    def loads_next_slideshow
      #next slideshow is loaded after the user scrolls to the bottom
      #the tests have already scrolled to the bottom to test lazy loading ads
      #So all we need to do at this point is count the number of slideshows
      wait_for { @driver.find_element(:css, ".js-infiniteContent_0.js-Node--slideshow").displayed? }
      first_slideshow   = find ".js-infiniteContent_0.js-Node--slideshow"
      second_slideshow  = find ".js-infiniteContent_1.js-Node--slideshow"

      if first_slideshow
        self.errors.add(:base, "First slideshow disappared from the page after the second was loaded")
      end
      if second_slideshow
        self.errors.add(:base, "Second slideshow was not loaded")
      end
    end

    def scroll_to_bottom_of_page
      @driver.execute_script("window.scrollTo(0,document.body.scrollHeight);")
    end

    # def relative_links_in_the_header
    #   links = (@driver.find_elements(:css, ".js-HC-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
    #   bad_links = links.map do |link|
    #     if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
    #       link unless link.include?("twitter")
    #     end
    #   end
    #   unless bad_links.compact.length == 0
    #     self.errors.add(:base, "There were links in the header that did not use relative paths: #{bad_links.compact}")
    #   end
    # end
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
