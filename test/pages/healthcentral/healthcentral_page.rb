require 'active_model'
require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/slide'
require_relative './concerns/ads_test_cases'

class HealthCentralPage
  attr_reader :driver, :proxy, :slides, :ords
  include HealthCentralOmniture 
  include HealthCentralAssets 
  include HealthCentralAds 

  SUB_CATEGORIES = ["Acid Reflux",
                    "ADHD",
                    "Allergy",
                    "Alzheimer's Disease",
                    "Anxiety",
                    "Asthma",
                    "Autism",
                    "Bipolar Disorder",
                    "Breast Cancer",
                    "Cholesterol",
                    "Chronic Pain",
                    "Cold & Flu",
                    "COPD",
                    "Depression",
                    "Diabetes",
                    "Digestive Health",
                    "Epilepsy",
                    "Erectile Dysfunction",
                    "Genital Herpes",
                    "Heart Disease",
                    "Hepatitis C",
                    "High Blood Pressure",
                    "Incontinence",
                    "Migraine",
                    "Multiple Sclerosis",
                    "Osteoarthritis",
                    "Osteoporosis",
                    "Rheumatoid Arthritis",
                    "Schizophrenia",
                    "Sexual Health",
                    "Skin Cancer",
                    "Skin Care",
                    "Sleep Disorders"]

  # def initialize(driver, proxy, fixture=nil)
  #   @driver       = driver
  #   @proxy        = proxy
  #   @slides       = []
  #   @ords         = {}
  #   @fixture      = fixture
  #   @report_suite = nil
  # end

  # def analytics_file
  #   has_file = false
  #   proxy.har.entries.each do |entry|
  #     if entry.request.url.include?('namespace.js')
  #       has_file = true
  #     end
  #   end
  #   has_file
  # end

  # def pharma_safe?
  #   (driver.execute_script("return EXCLUSION_CAT") != 'community')
  # end

  # def ugc
  #   ad_calls   = []
  #   ugc_values   =  []

  #   proxy.har.entries.find do |entry|
  #   if entry.request.url.include?('ad.doubleclick.net/N3965')
  #     ad_calls   << entry.request.url
  #     ugc_values << entry.request.url.split('ugc=').last.split(';').first
  #   end
  #   end

  #   ugc_values.uniq.to_s
  # end

  # def has_correct_title?
  #   title = driver.title 
  #   if title
  #     title.split('-').map {|x| x.gsub(' ', '')}.select { |x| x.length > 0 }.compact.length >= 2
  #   else
  #     false
  #   end
  # end

  # def go_through_slide_show
  #   slides = driver.find_elements(:css, ".Slide-content-slide-container")
  #   slides.each_with_index do |slide, index|
  #     unless index == (slides.length - 1)
  #       ads = ads_on_page(3)
  #       @slides << HealthCentralSlide.new(:ads => ads)
  #       @driver.find_element(:css, ".Slideshow-controls-next-button-label").click
  #       wait_for_ajax
  #     end
  #   end
  #   @slides << HealthCentralSlide.new(:ads => ads_on_page(3))
  # end 

  # def go_through_quiz
  #   questions = driver.find_elements(:css, ".answering-form")
  #   questions.each_with_index do |question, index|
  #     @slides << HealthCentralSlide.new(:ads => ads_on_page(3))
  #     unless index == (questions.length - 1)
  #       questions_on_page = driver.find_elements(:css, "label.option").select { |q| q.displayed? }
  #       questions_on_page.first.click
  #       wait_for_ajax
  #       # if index < 3
  #       #   check_for_modal(".modalCloseImg")
  #       # end
  #       next_buttons = driver.find_elements(:css, "span.Quiz-controls-next-button-label")
  #       next_button = next_buttons.select {|button| button.displayed?}.first
  #       next_button.click
  #       wait_for_ajax
  #     end
  #   end
  # end

  def logo_present?
    logo_1 = @driver.find_element(:css, "span.LogoHC-part1")
    logo_2 = @driver.find_element(:css, "span.LogoHC-part2")

    (logo_1.text == "Health" && logo_2.text == "Central")
  end

  def has_unique_ads?
    raise NotImplementedError
  end

  def has_correct_title?
    title = @driver.title
    title.scan(/^[^\-]*-[\s+\w+]+/).length == 1
  end

  def self.ads_on_page(args)
    expected_number_of_ads  = args[:expected_number_of_ads]
    ads_per_page            = args[:ads_per_page] || 3
    all_ads                 = args[:all_ads]

    unless !ads_per_page.nil? 
      raise AdsPerPageIsNil
    end
    unless !all_ads.nil?
      raise AllAdsIsNil
    end
    unless !expected_number_of_ads.nil?
      raise ExpectedNumberOfAdsIsNil
    end

    
    @ads_on_page_view.map { |ad| HealthCentralAds::Ads.new(ad) }
  end

  def self.get_all_ads(proxy)
    @proxy = proxy
    ad_calls = @proxy.har.entries.map do |entry|
      if entry.request.url.include?('ad.doubleclick.net/N3965')
        entry.request.url
      end
    end
    ad_calls.compact
  end

  def check_for_modal(css)
    begin
      modal_close = driver.find_element(:css, css)
    rescue Selenium::WebDriver::Error::NoSuchElementError
    end
    if modal_close
      modal_close.click
    end
  end

  def omniture
    raise NotImplementedError
  end 

  def assets
    raise NotImplementedError
  end

  def global_test_cases
    raise NotImplementedError
  end

  def functionality
    raise NotImplementedError
  end

  def get_site_urls
    site_urls = @proxy.har.entries.map do |entry|
      if entry.request.url.include?("healthcentral")
        entry.request.url
      end
    end
    site_urls.compact
  end
end




