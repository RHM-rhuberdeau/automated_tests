class HealthCentralPage
  attr_reader :driver, :proxy, :slides, :ords

  def initialize(driver, proxy)
    @driver  = driver
    @proxy   = proxy
    @slides  = []
    @ords    = {}
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

  def has_unloaded_assets?
    assets = unloaded_assets
    !unloaded_assets.empty?
  end

  def unloaded_assets
    @unloaded_assets ||= @proxy.har.entries.map do |entry|
       if (entry.request.url.split('.com').first.include?("#{HC_BASE_URL}") || entry.request.url.split('.com').first.include?("#{HC_DRUPAL_URL}") ) && entry.response.status != 200
         entry.request.url
      end
    end
    @unloaded_assets.compact
  end

  def wrong_assets
    @wrong_assets ||= @proxy.har.entries.map do |entry|
      if entry.request.url.include?(wrong_asset_host)
        entry.request.url
      end
    end
    @wrong_assets.compact
  end

  def right_assets
    @right_assets ||= @proxy.har.entries.map do |entry|
      if entry.request.url.include?(ASSET_HOST)
        entry.request.url
      end
    end
    @right_assets.compact
  end

  def wrong_asset_host
    (["qa.healthcentral.", "qa1.healthcentral","qa2.healthcentral.","qa3.healthcentral.", "www.healthcentral.com", "alpha.healthcentral", "stage.healthcentral."] - [ASSET_HOST]).to_s
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

  def has_unique_ads?
    ord_values = @slides.map { |slide| slide.ord_values}
    ord_values = ord_values.compact.uniq
    (ord_values.length == @slides.length && ord_values.length > 0)
  end

  def ads_on_page(range=nil)
    all_ads = get_all_ads
    if all_ads.length == 3
      all_ads = all_ads
    elsif all_ads.length > 3
      all_ads = all_ads[-3, range]
    elsif all_ads.length < 3
      all_ads = all_ads
    end
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
    hash.each {|k,v| send("#{k}=",v)}
  end

  def parse_ad_into_hash(ad_string)
    ad_string = ad_string.to_s
    array = ad_string.split(';')
    hash ={ url: array[0], ugc: array[1].split('=').last, device: array[4].split('=').last, tile: array[7].split('=').last, sz: array[8].split('sz=').last, cat: array[11].split('=').last, sc: array[10].split('=').last, ord: array.last.split('=').last}
  end
end




