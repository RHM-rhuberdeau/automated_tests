require 'active_model'
require 'capybara'

require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/slide'
require_relative './concerns/ads_test_cases'
require_relative './concerns/header'
require_relative './concerns/footer'
require_relative './concerns/seo'

class HealthCentralPage
  attr_reader :driver, :proxy, :slides, :ords
  include HealthCentralOmniture 
  include HealthCentralAssets 
  include HealthCentralAds 
  include HealthCentralHeader
  extend Capybara::DSL

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
                    "Lung Cancer",
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
                    
  SITE_HOSTS = ["http://qa.healthcentral.", "http://qa1.healthcentral.","http://qa2.healthcentral.","http://qa3.healthcentral.", "http://qa4.healthcentral.", "http://www.healthcentral.", "http://alpha.healthcentral.", "http://staging.healthcentral."]

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

  def self.get_all_ads
    begin
      page.execute_script "window.stop();"
    rescue Timeout::Error, Net::ReadTimeout
    end
    sleep 0.25

    traffic_calls = get_network_traffic
    ad_calls      = traffic_calls.map do |entry|
      unless entry.empty?
        if self.dfp_ad_request(entry.first) && (entry.last == 200)
          entry.first
        end
      end
    end
    
    ad_calls.compact
  end

  def self.dfp_ad_request(url)
    # There are DFP ads and Mediaconductor ads
    # We only care about DFP ads 
    # Mediaconductor ads do not have a tile value, so we exclude ad calls that don't have them
    # This means that if a DFP ad does not have a tile value, we won't know about it
    # Joy of joys
    if url.include?("ad.doubleclick.net/N3965") && url.include?("tile=") 
      unless url.include?("Criteo")
        true
      end
    end
  end

  def self.get_network_traffic
    network_traffic = []
    page.driver.network_traffic.each do |request|
      request.response_parts.uniq(&:url).each do |response|
        network_traffic << ["#{response.url}", response.status]
      end
    end
    network_traffic
  end

  def omniture(args)
    HealthCentralPage.open_omniture_debugger
    omniture_text = HealthCentralPage.get_omniture_from_debugger
    begin
      omniture = HealthCentralOmniture::Omniture.new(omniture_text: omniture_text, fixture: @fixture, url: args[:url])
    rescue HealthCentralOmniture::OmnitureIsBlank
      omniture = OpenStruct.new(:errors => OpenStruct.new(:messages => {:omniture => "Omniture was blank"}), :validate => '')
    end
  end

  def self.open_omniture_debugger
    execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
    sleep 1
  end

  def self.get_omniture_from_debugger
    second_window   = page.driver.browser.window_handles.last
    @omniture_lines = []

    page.within_window second_window do
      wait_for { all('table.debugtable').last.visible? }
      begin
        uncheck "auto_refresh"
      rescue Capybara::Ambiguous
        all("input[name='auto_refresh']").first.click
      end
      omniture_node   = find('td#request_list_cell').all('table.debugtable').last
      @omniture_lines = omniture_node.all('tr').map do |line|
        line.text
      end

      if @omniture_lines.empty?
        sleep 1
        wait_for { all('table.debugtable').last.visible? }
        omniture_node   = find('td#request_list_cell').all('table.debugtable').last
        @omniture_lines = omniture_node.all('tr').map do |line|
          line.text
        end
      end
    end

    @omniture_lines
  end

  def assets(args)
    HealthCentralAssets::Assets.new(:base_url => args[:base_url], :host => args[:host], :driver => args[:driver])
  end

  def seo(args)
    HealthCentralSeo::Seo.new
  end

  def global_test_cases
    GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
  end

  def functionality
    raise NotImplementedError
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




