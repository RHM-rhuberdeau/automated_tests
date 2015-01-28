require File.dirname(__FILE__) + '/config/automation_config';
require File.dirname(__FILE__) + '/config/proxy/settings';
require 'minitest/autorun' 
require 'shoulda/context' 
require 'selenium-webdriver' 
require 'browsermob/proxy'
require 'timeout'

HC_BASE_URL  = Configuration["healthcentral"]["base_url"]
HC_DRUPAL_URL = Configuration["healthcentral"]["drupal_url"]
BW_BASE_URL  = Configuration["berkley"]["base_url"]
ASSET_HOST   = Configuration["asset_host"]
MED_BASE_URL = Configuration["medtronic"]["base_url"]
COLLECTION_URL = Configuration["collection_url"]

def firefox
  Selenium::WebDriver::Firefox::Binary.path= '/usr/bin/firefox'
  @driver = Selenium::WebDriver.for :firefox
  @driver.manage.window.resize_to(1024,728)
  @driver.manage.timeouts.implicit_wait = 5
end

def firefox_with_proxy
  proxy_location = Settings.location
	server = BrowserMob::Proxy::Server.new(proxy_location)
	server.start
	@proxy = server.create_proxy
	@profile = Selenium::WebDriver::Firefox::Profile.new
	@profile.proxy = @proxy.selenium_proxy
	@driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(1024,728)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_with_secure_proxy
  proxy_location = Settings.location
  server = BrowserMob::Proxy::Server.new(proxy_location)
  server.start
  @proxy = server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(1024,728)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_remote_proxy
  proxy_location = Settings.location
  server = BrowserMob::Proxy::Server.new(proxy_location)
  server.start
  @proxy = server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  caps = Selenium::WebDriver::Remote::Capabilities.new(
    :browser_name => "firefox", :firefox_profile => @profile
  )
  @driver = Selenium::WebDriver.for(
    :remote,
    url: 'http://jenkins.choicemedia.com:4444//wd/hub',
    desired_capabilities: caps) 
  @driver.manage.window.resize_to(1024,900)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_remote
  @driver = Selenium::WebDriver.for(
    :remote,
    url: 'http://jenkins.choicemedia.com:4444//wd/hub',
    desired_capabilities: :firefox)
  @driver.manage.window.resize_to(1024,900)
  @driver.manage.timeouts.implicit_wait = 5
end

def phantomjs
  @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:8001'
end

def wait_for_page_to_load
  begin
    Timeout::timeout(3) do
      loop until finished_loading?
    end
  rescue Timeout::Error
    @driver.execute_script "window.stop()"
  end
end

def finished_loading?
  state = @driver.execute_script "return window.document.readyState"
  sleep 0.5
  if state == "complete"
  	true
  else
  	false
  end
end

def wait_for_immersive_to_load
  begin
    Timeout::timeout(8) do
      loop until immersive_loaded?
    end
  rescue Timeout::Error
    @driver.execute_script "window.stop()"
  end
end

def immersive_loaded?
  sleep 0.5
  begin
    if @driver.find_element(:css, "#loader")
      false
    else
      true
    end
  rescue Selenium::WebDriver::Error::NoSuchElementError
    true
  end
end

def wait_for_ajax
  begin
    Timeout::timeout(4) do
      loop until finished_all_ajax_requests?
    end
  rescue Timeout::Error
    @driver.execute_script("window.stop();")
  end
end

def finished_all_ajax_requests?
  begin
    Timeout::timeout(3) do
      loop until jquery_is_defined?
    end
  rescue Timeout::Error
    @driver.execute_script("window.stop();")
  end

  begin
    Timeout::timeout(3) do
      loop until zero_ajax_requests?
    end
  rescue Timeout::Error
    @driver.execute_script("window.stop();")
  end
end

def jquery_is_defined?
  sleep 0.5
  @driver.execute_script("return jQuery !== 'undefined'")
end

def zero_ajax_requests?
  sleep 0.5
  if @driver.execute_script("return jQuery !== 'undefined'") == true
    @driver.execute_script('return jQuery.active').zero?
  else
    false
  end
end

def visit(url)
  begin
    Timeout::timeout(5) do
      @driver.navigate.to url 
    end
  rescue Timeout::Error
  	@driver.execute_script "window.stop()"
  end
  wait_for_page_to_load
end

def evaluate_script(script)
  @driver.execute_script "return #{script}"
end

def wrong_asset_host
  (["qa.healthcentral.", "www.healthcentral.com", "alpha.healthcentral"] - [ASSET_HOST]).to_s
end

def page_has_ad(ad_url)
  ads = []
  @proxy.har.entries.each do |entry|
    if entry.request.url.include?(ad_url)
      ads << entry.request.url
    end
  end
  if ads.compact.length >= 1
    true
  else
    false
  end
end