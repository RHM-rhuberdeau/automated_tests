require 'active_model'

class HealthCentralPage
  attr_reader :driver, :proxy, :slides, :ords

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

  def initialize(driver, proxy, fixture=nil)
    @driver  = driver
    @proxy   = proxy
    @slides  = []
    @ords    = {}
    @fixture = fixture
  end

  def analytics_file
    has_file = false
    proxy.har.entries.each do |entry|
      if entry.request.url.include?('/sites/all/modules/custom/assets_pipeline/public/js/namespace.js')
        has_file = true
      end
    end
    has_file
  end

  def pharma_safe?
    (driver.execute_script("return EXCLUSION_CAT") != 'community')
  end

  def ugc
    ad_calls   = []
    ugc_values   =  []

    proxy.har.entries.find do |entry|
    if entry.request.url.include?('ad.doubleclick.net/N3965')
      ad_calls   << entry.request.url
      ugc_values << entry.request.url.split('ugc=').last.split(';').first
    end
    end

    ugc_values.uniq.to_s
  end

  def has_correct_title?
    title = driver.title 
    if title
      title.split('-').map {|x| x.gsub(' ', '')}.select { |x| x.length > 0 }.compact.length >= 2
    else
      false
    end
  end

  def go_through_slide_show
    slides = driver.find_elements(:css, ".Slide-content-slide-container")
    slides.each_with_index do |slide, index|
      unless index == (slides.length - 1)
        @driver.find_element(:css, ".Slideshow-controls-next-button-label").click
        wait_for_ajax
        @slides << HealthCentralSlide.new(:ads => ads_on_page(3))
      end
    end
  end 

  def go_through_quiz
    questions = driver.find_elements(:css, ".answering-form")
    questions.each_with_index do |question, index|
      @slides << HealthCentralSlide.new(:ads => ads_on_page(3))
      unless index == (questions.length - 1)
        questions_on_page = driver.find_elements(:css, "label.option").select { |q| q.displayed? }
        questions_on_page.first.click
        wait_for_ajax
        # if index < 3
        #   check_for_modal(".modalCloseImg")
        # end
        next_buttons = driver.find_elements(:css, "span.Quiz-controls-next-button-label")
        next_button = next_buttons.select {|button| button.displayed?}.first
        next_button.click
        wait_for_ajax
      end
    end
  end

  def logo_present?
    logo_1 = @driver.find_element(:css, "span.LogoHC-part1")
    logo_2 = @driver.find_element(:css, "span.LogoHC-part2")

    (logo_1.text == "Health" && logo_2.text == "Central")
  end

  def has_unique_ads?
    ord_values = @slides.map { |slide| slide.ord_values}
    ord_values = ord_values.compact.uniq
    (ord_values.length == @slides.length && ord_values.length > 0)
  end

  def ads_on_page(range=nil)
    if range == nil
      range = 3
    end

    all_ads = get_all_ads

    if all_ads.length == 3
      all_ads = all_ads
    elsif all_ads.length > 3
      all_ads = all_ads[-3, range]
    elsif all_ads.length < 3
      all_ads = all_ads
    end
    
    all_ads.map { |ad| HealthCentralAds.new(ad) }
  end

  def get_all_ads
    ad_calls = proxy.har.entries.map do |entry|
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
    @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
    sleep 1
    second_window = @driver.window_handles.last
    @driver.switch_to.window second_window
    omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
    omniture = Omniture.new(omniture_text, @fixture)
  end 

  def assets
    all_images      = @driver.find_elements(tag_name: 'img')
    unloaded_assets = unloaded_assets
    Assets.new(:proxy => @proxy, :imgs => all_images)
  end

  def global_test_cases
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

class HealthCentralSlide
  attr_reader :text, :ads

  def initialize(text=nil, ads)
    @text = text
    @ads  = []
    create_ads(ads[:ads])
  end

  def create_ads(ads)
    ads.each do |ad|
      @ads << HealthCentralAds.new(ad)
    end
  end

  def ord_values
    ords = ads.map { |ad| ad.ord }
    ords = ords.uniq!
  end
end

class HealthCentralAds
  attr_accessor :url, :ugc, :device, :tile, :sz, :cat, :sc, :ord

  def initialize(ad_string)
    ad_from_string(ad_string)
  end

  def ad_from_string(ad_string)
    hash = parse_ad_into_hash(ad_string)
    hash.keep_if{|k,v| k == "url" || k == "ugc" || k == "device" || k == "tile" || k == "sz" || k == "cat" || k == "sc" || k == "ord"}
    hash.each {|k,v| send("#{k}=",v)}
  end

  def parse_ad_into_hash(ad_string)
    ad_string = ad_string.to_s
    array = ad_string.split(';')
    hash = {}
    hash['url'] = array.delete_at(0)
    array.each do |a|
      b = a.split('=')
      hash[b[0]] = b.last
    end
    # hash ={ url: array[0], ugc: array[1].split('=').last, device: array[4].split('=').last, tile: array[7].split('=').last, sz: array[8].split('sz=').last, cat: array[11].split('=').last, sc: array[10].split('=').last, ord: array.last.split('=').last}
    hash
  end
end

class Omniture
  include ::ActiveModel::Validations

  def self.attr_list
    [:pageName, :channel, :prop1, :prop2, :prop4, :prop5, :prop6, :prop7, :prop10, :prop12, :prop13, :prop16, :prop17, :prop22, :prop29, :prop30, :prop37, :prop38, :prop39, :prop40, :prop42, :prop43, :prop44, :prop45, :eVar17, :events]
  end

  attr_accessor *attr_list
  validate :values_match_fixture

  def initialize(omniture_string, fixture)
    @fixture  = fixture
    array     = omniture_string.lines
    index     = array.index { |x| x.include?("pageName") }
    range     = array.length - index
    new_array = array[index, range]
    omniture_from_array(new_array)
  end

  def omniture_from_array(array_from_omniture_debugger)
    hash = {}
    array_from_omniture_debugger.each do |omniture_line|
      omniture_hash = omniture_line_to_hash(omniture_line)
      if omniture_hash
        hash[omniture_hash.keys.first] = omniture_hash.values.first
      end
    end
    hash.each {|k,v| send("#{k}=",v)}
  end

  def omniture_line_to_hash(omniture_line)
    hash = {}
    Omniture.attr_list.each do |attribute|
      attribute = attribute.to_s
      if omniture_line.include?("#{attribute} ")
        key = omniture_line.slice!(attribute)
        value = omniture_line.strip
        hash = {key => value}
      end
    end
    if hash.empty?
      nil
    else
      hash
    end
  end

  def values_match_fixture
    Omniture.attr_list.each do |attribute|
      if @fixture.send(attribute).to_s != self.send(attribute).to_s
        self.errors.add(:base, "#{attribute} was #{self.send(attribute)} not #{@fixture.send(attribute)}")
      end
    end
  end
end

class Assets
  include ::ActiveModel::Validations

  validate :assets_using_correct_host
  validate :no_broken_images
  validate :no_unloaded_assets

  def initialize(args)
    @proxy     = args[:proxy]
    @all_imgs  = args[:imgs]
  end

  def wrong_asset_hosts
    (["http://qa.healthcentral.", "http://qa1.healthcentral","http://qa2.healthcentral.","http://qa3.healthcentral.", "http://qa4.healthcentral.", "http://www.healthcentral.", "http://alpha.healthcentral", "http://stage.healthcentral."] - [ASSET_HOST])
  end

  def assets_using_correct_host
    wrong_assets = page_wrong_assets
    unless wrong_assets.empty?
      self.errors.add(:base, "there were assets loaded from the wrong environment #{wrong_assets}")
    end
  end

  def page_wrong_assets
    site_urls = @proxy.har.entries.map do |entry|
      if entry.request.url.include?("healthcentral")
        entry.request.url
      end
    end

    site_urls = site_urls.compact

    wrong_assets_on_page = site_urls.map do |site_url|
      if url_has_wrong_asset_host(site_url)
        site_url
      end
    end

    wrong_assets_on_page.compact
  end

  def url_has_wrong_asset_host(url)
    bad_host = wrong_asset_hosts.map do |host_url|
      if url.index(host_url) == 0
        true
      end
    end
    bad_host.compact.length > 0
  end

  def no_unloaded_assets
    unloaded_assets = page_unloaded_assets.compact
    if unloaded_assets.empty? == false
      self.errors.add(:base, "there were unloaded assets #{unloaded_assets}")
    end
  end

  def page_unloaded_assets
    @unloaded_assets ||= @proxy.har.entries.map do |entry|
       if (entry.request.url.split('.com').first.include?("#{HC_BASE_URL}") || entry.request.url.split('.com').first.include?("#{HC_DRUPAL_URL}") ) && entry.response.status != 200
         entry.request.url
      end
    end
    @unloaded_assets.compact
  end

  def url_has_wrong_asset_host(url)
    bad_host = wrong_asset_hosts.map do |host_url|
      if url.index(host_url) == 0
        true
      end
    end
    bad_host.compact.length > 0
  end

  def right_assets
    right_assets = @proxy.har.entries.map do |entry|
      if entry.request.url.include?(ASSET_HOST)
        entry.request.url
      end
    end
    right_assets.compact
  end

  def no_broken_images
    broken_images = []
    @all_imgs.each do |img|
      broken_images << @proxy.har.entries.find do |entry|
        entry.request.url == img.attribute('src') && entry.response.status == 404
      end
    end
    broken_images = broken_images.compact.collect {|x| x.request.url }
    unless broken_images.compact.empty?
      self.errors.add(:base, "broken images on the page #{broken_images}")
    end
  end
end




