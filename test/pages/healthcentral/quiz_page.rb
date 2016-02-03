require_relative './healthcentral_page'

module HealthCentral
  class QuizPage < HealthCentralPage 
    def initialize(args)
      @driver       = args[:driver]
      @proxy        = args[:proxy]
      @fixture      = args[:fixture]
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :updates_the_ads_between_slides

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
      @slides = []
    end

    def updates_the_ads_between_slides
      ads = go_through_quiz
      unique_ads = slides_have_unique_ads?
      unless unique_ads == true
        self.errors.add(:base, "One of the slides had multiple ord values.")
      end
      @slides.each_with_index do |slide, index|
        if index == 0
          unless slide.ads.length == 3
            self.errors.add(:base, "Slide #{index} had the wrong number of ads. It had #{slide.ads.length} ads")
          end
        else
          unless slide.ads.length == 2
            self.errors.add(:base, "Slide #{index} had the wrong number of ads. It had #{slide.ads.length} ads")
          end
        end
      end
    end

    def go_through_quiz
      @ads = {}
      questions = @driver.find_elements(:css, ".answering-form")
      questions.each_with_index do |question, index|
        @all_ads = HealthCentralPage.get_all_ads(@proxy)
        if index == 0
          @ads[index] = @all_ads
        else
          @ads[index] = @all_ads - @ads.flatten(2)
        end

        ads     = @ads[index].map { |ad| HealthCentralAds::Ads.new(ad) }
        @slides << HealthCentralSlide::Slide.new(:ads => ads)

        begin
          questions_on_page = @driver.find_elements(:css, "label.option").select { |q| q.displayed? }
        rescue Selenium::WebDriver::Error::UnknownError
        end
        questions_on_page.first.click
        begin
          wait_for      { @driver.find_element(:css, "span.Quiz-controls-next-button-label").displayed? }
        rescue Selenium::WebDriver::Error::UnknownError
        end
        next_buttons  = @driver.find_elements(:css, "span.Quiz-controls-next-button-label")
        next_button   = next_buttons.select {|button| button.displayed?}.first
        if next_button
          next_button.click
        end
        sleep 0.25
      end
      all_ads                           = HealthCentralPage.get_all_ads(@proxy)
      @ads[questions.length - 1]        = all_ads - @ads.flatten(2)
      ads                               = @ads[questions.length - 1].map { |ad| HealthCentralAds::Ads.new(ad) }
      @slides                           << HealthCentralSlide::Slide.new(:ads => ads)
    end

    def slides_have_unique_ads?
      ord_values = @slides.map { |slide| slide.ord_values}
      ord_values = ord_values.compact.uniq
      (ord_values.length == @slides.length && ord_values.length > 0)
    end
  end
end