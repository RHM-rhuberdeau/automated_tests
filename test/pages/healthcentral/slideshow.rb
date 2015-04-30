require_relative './healthcentral_page'

module HealthCentral
  class SlideshowPage < HealthCentralPage
    def initialize(driver, proxy, fixture=nil)
      @driver       = driver
      @proxy        = proxy
      @fixture      = fixture
    end

    def assets
      all_images = @driver.find_elements(tag_name: 'img')
      HealthCentralAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :updates_the_ads_between_slides
    validate :relative_links_in_the_header

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
      @slides = []
    end

    def updates_the_ads_between_slides
      ads = go_through_slides
      unique_ads = slides_have_unique_ads?
      unless unique_ads == true
        self.errors.add(:base, @ads.inspect)
      end
    end

    def relative_links_in_the_header
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

    def go_through_slides
      @ads = {}
      slideshow_slides = @driver.find_elements(:css, ".Slide-content-slide-container")
      slideshow_slides.each_with_index do |slide, index|
        unless index == (slideshow_slides.length - 1)
          @all_ads = HealthCentralPage.get_all_ads(@proxy)
          if index == 0
            @ads[index] = @all_ads
          else
            @ads[index] = @all_ads - @ads.flatten(2)
          end

          ads     = @ads[index].map { |ad| HealthCentralAds::Ads.new(ad) }
          @slides << HealthCentralSlide::Slide.new(:ads => ads)
          @driver.find_element(:css, ".Slideshow-controls-next-button-label").click
          wait_for_ajax
        end
      end

      all_ads                           = HealthCentralPage.get_all_ads(@proxy)
      @ads[slideshow_slides.length - 1] = all_ads - @ads.flatten(2)
      ads                               = @ads[slideshow_slides.length - 1].map { |ad| HealthCentralAds::Ads.new(ad) }
      @slides                           << HealthCentralSlide::Slide.new(:ads => ads)
    end

    def slides_have_unique_ads?
      ord_values = @slides.map { |slide| slide.ord_values}
      ord_values = ord_values.compact.uniq
      (ord_values.length == @slides.length && ord_values.length > 0)
    end
  end
end
