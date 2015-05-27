require_relative './berkeley_page'

class BerkeleySlideShowPage < BerkeleyPage
  attr_reader :driver, :proxy

  def initialize(args)
  	@driver = args[:driver]
  	@proxy	= args[:proxy]
  	@old_ad_calls = []
  end

  def assets
    all_images = @driver.find_elements(tag_name: 'img')
    BerkeleyAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
  end

  def old_ad_calls
  	@old_ad_calls
  end

  def old_ad_calls=(value)
  	@old_ad_calls = value
  end

  def slideshow
  	driver.find_elements(:css, "ul.slides").first
  end

  def slides
  	driver.find_elements(:css, "div.flex-viewport ul.slides li")
  end

  def ads_on_page
  	all_ads = all_ad_calls
  	current_ad_calls = all_ads - old_ad_calls
  	old_ad_calls = all_ads
  	current_ad_calls
  end

  def all_ad_calls
  	all_ad_calls = []
  	proxy.har.entries.find do |entry|
  	  if entry.request.url.include?('ad.doubleclick.net/N3965')
  	  	all_ad_calls << entry.request.url
  	  end
  	end
  	all_ad_calls
  end
end