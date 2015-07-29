require 'active_model'
require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/slide'
require_relative './concerns/ads_test_cases'
require_relative './concerns/header'
require_relative './concerns/footer'

class HealthCentralPage
  attr_reader :driver, :proxy, :slides, :ords
  include HealthCentralOmniture 
  include HealthCentralAssets 
  include HealthCentralAds 
  include HealthCentralHeader

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
                    
  SITE_HOSTS = ["http://qa.healthcentral.", "http://qa1.healthcentral.","http://qa2.healthcentral.","http://qa3.healthcentral.", "http://qa4.healthcentral.", "http://www.healthcentral.", "http://alpha.healthcentral.", "http://stage.healthcentral."]

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

    if ad_calls.compact.length < 3
      sleep 2
      ad_calls = @proxy.har.entries.map do |entry|
        if entry.request.url.include?('ad.doubleclick.net/N3965')
          entry.request.url
        end
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
    open_omniture_debugger
    omniture_text = get_omniture_from_debugger
    begin
      omniture = HealthCentralOmniture::Omniture.new(omniture_text, @fixture)
    rescue HealthCentralOmniture::OmnitureIsBlank
      omniture = OpenStruct.new(:errors => OpenStruct.new(:messages => {:omniture => "Omniture was blank"}), :validate => '')
    end
  end

  def assets(args)
    HealthCentralAssets::Assets.new(:proxy => @proxy, :driver => @driver, :base_url => args[:base_url])
  end

  def global_test_cases
    GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
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




