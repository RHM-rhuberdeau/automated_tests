require_relative './healthcentral_page'

module HealthCentralSlideshow
  class SlideshowPage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
      @fixture          = args[:fixture]
    end

    def ads_test_cases(args)
      AdsTestCases.new(:driver => @driver, :ad_site => args[:ad_site], :ad_categories => args[:ad_categories])
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

    validate :updates_the_ads_between_slides
    validate :relative_links_in_the_header
    validate :includes_publish_date
    validate :includes_updated_date

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
    end

    def slides
      @slides
    end

    def slides=(value)
      @slides = value
    end

    def updates_the_ads_between_slides
      self.slides = Array.new
      ads = self.go_through_slides
      unique_ads = slides_have_unique_ads?
      unless unique_ads == true
        self.errors.add(:base, "One of the slides had multiple ord values.")
      end
      @slides.each_with_index do |slide, index|
        unless slide.ads.length == 3
          self.errors.add(:base, "Slide #{index} had the wrong number of ads. It had #{slide.ads.length} ads")
        end
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

    def includes_publish_date
      publish_date = find  "span.Page-info-publish-date"
      unless publish_date
        self.errors.add(:base, "Page was missing a publish date")
      end
      if publish_date
        unless publish_date.text.length >= 1
          self.errors.add(:base, "Publish date was in the wrong format: #{publish_date.text}")
        end
      end
    end

    def includes_updated_date
      updated_date = find "span.Page-info-publish-updated"
      unless updated_date
        self.errors.add(:base, "Page was missing an updated date")
      end
      if updated_date
        date = updated_date.text.gsub("updated", '').strip if updated_date
        unless date.length >= 1
          self.errors.add(:base, "Publish date was in the wrong format: #{updated_date.text}")
        end
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
          self.slides << HealthCentralSlide::Slide.new(:ads => ads)
          @driver.find_element(:css, ".Slideshow-controls-next-button-label").click
          sleep 0.25
        end
      end

      all_ads                           = HealthCentralPage.get_all_ads(@proxy)
      @ads[slideshow_slides.length - 1] = all_ads - @ads.flatten(2)
      ads                               = @ads[slideshow_slides.length - 1].map { |ad| HealthCentralAds::Ads.new(ad) }
      self.slides                           << HealthCentralSlide::Slide.new(:ads => ads)
    end

    def slides_have_unique_ads?
      ord_values = @slides.map { |slide| slide.ord_values}
      ord_values = ord_values.compact.uniq
      (ord_values.length == @slides.length && ord_values.length > 0)
    end
  end

  class AdsTestCases
    include ::ActiveModel::Validations

    validate :correct_ad_site
    validate :correct_ad_categories

    def initialize(args)
      @driver                 = args[:driver]
      @expected_ad_categories = args[:ad_categories]
      @expected_ad_site       = args[:ad_site]
    end

    def correct_ad_site
      ad_site = evaluate_script("AD_SITE")
      unless ad_site == @expected_ad_site
        self.errors.add(:ad_tags, "ad_site was #{ad_site} not #{@expected_ad_site}")
      end
    end

    def correct_ad_categories
      ad_categories = evaluate_script("AD_CATEGORIES")
      unless ad_categories == @expected_ad_categories
        self.errors.add(:ad_tags, "ad_categories was #{ad_categories} not #{@expected_ad_categories}")
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
