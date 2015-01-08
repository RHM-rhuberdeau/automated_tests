require File.dirname(__FILE__) + '/automation_config';
require File.dirname(__FILE__) + '/support/collection_sync';
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
  @driver = Selenium::WebDriver.for :firefox
end

def firefox_with_proxy
	server = BrowserMob::Proxy::Server.new('/Users/rhuberdeau/Downloads/browsermob-proxy-2.0-beta-9/bin/browsermob-proxy')
	server.start
	@proxy = server.create_proxy
	@profile = Selenium::WebDriver::Firefox::Profile.new
	@profile.proxy = @proxy.selenium_proxy
	@driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.maximize
end

def fire_fox_with_secure_proxy
  server = BrowserMob::Proxy::Server.new('/Users/rhuberdeau/Downloads/browsermob-proxy-2.0-beta-9/bin/browsermob-proxy')
  server.start
  @proxy = server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.maximize
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

def wait_for_ajax
  begin
    Timeout::timeout(3) do
      loop until finished_all_ajax_requests?
    end
  rescue Timeout::Error
    @driver.execute_script("window.stop();")
  end
end

def finished_all_ajax_requests?
  @driver.execute_script('return jQuery.active').zero?
  sleep 0.5
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

def wrong_asset_host
  (["qa.healthcentral.", "www.healthcentral.com", "alpha.healthcentral"] - [ASSET_HOST]).to_s
end