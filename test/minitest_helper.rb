require File.dirname(__FILE__) + '/config/automation_config';
require File.dirname(__FILE__) + '/config/proxy/settings';
require 'minitest/autorun' 
require 'shoulda/context' 
require 'selenium-webdriver' 
require 'browsermob/proxy'
require 'timeout'

#### HEALTHCENTRAL
HC_BASE_URL    = Configuration["healthcentral"]["base_url"]
HC_DRUPAL_URL  = Configuration["healthcentral"]["drupal_url"]
IMMERSIVE_URL  = Configuration["healthcentral"]["immersive"]
COLLECTION_URL = Configuration["collection_url"]
ASSET_HOST     = Configuration["asset_host"]
MED_BASE_URL   = Configuration["medtronic"]["base_url"]

#### BERKELEY WELLNESS
BW_BASE_URL    = Configuration["berkeley"]["base_url"]
BW_ASSET_HOST  = Configuration["berkeley"]["asset_host"]

#### THE BODY
BODY_URL            = Configuration["thebody"]["base_url"]
THE_BODY_ASSET_HOST = Configuration["thebody"]["asset_host"]

def firefox
  # Selenium::WebDriver::Firefox::Binary.path= '/opt/firefox/firefox'
  # Selenium::WebDriver::Firefox::Binary.path= '/Applications/Firefox.app/Contents/MacOS/firefox'
  @driver = Selenium::WebDriver.for :firefox
  @driver.manage.window.resize_to(1224,1000)
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
  @driver.manage.window.resize_to(1224,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_with_secure_proxy
  proxy_location = Settings.location
  server = BrowserMob::Proxy::Server.new(proxy_location)
  begin
    server.start
  rescue
  end
  @proxy = server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(1224,1000)
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
  @driver.manage.window.resize_to(1224,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def mobile_fire_fox_with_secure_proxy
  proxy_location = Settings.location
  server = BrowserMob::Proxy::Server.new(proxy_location)
  begin
    server.start
  rescue
  end
  @proxy = server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  # @profile['general.useragent.override'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25'
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(425,960)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_remote
  @driver = Selenium::WebDriver.for(
    :remote,
    url: 'http://jenkins.choicemedia.com:4444//wd/hub',
    desired_capabilities: :firefox)
  @driver.manage.window.resize_to(1224,1000)
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
  end
  sleep 0.5
end

def wait_for
  begin
    Selenium::WebDriver::Wait.new(:timeout => 3).until { yield }
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
    false
  rescue Net::ReadTimeout
    false
  end
end

#Find an element by css 
#If the element.diplayed? == true then return the element
#Otherwise return nil
def find(css)
  begin
    node = @driver.find_element(:css, css)
    node = nil if ( node.displayed? == false )
  rescue Selenium::WebDriver::Error::NoSuchElementError
    node = nil
  end
  node
end

def scroll_to_bottom_of_page
  @driver.execute_script("window.scrollTo(0,document.body.scrollHeight);")
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

def open_omniture_debugger
  @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
  sleep 1
end

def get_omniture_from_debugger
  original_window = @driver.window_handles.first
  second_window   = @driver.window_handles.last

  @driver.switch_to.window second_window
  wait_for { @driver.find_element(:css, 'td#request_list_cell').displayed? }
  omniture_node = find 'td#request_list_cell'
  begin
    omniture_text = omniture_node.text if omniture_node
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    omniture_text = nil
  end
  if omniture_text == nil
    sleep 1
    wait_for { @driver.find_element(:css, 'td#request_list_cell').displayed? }
    omniture_node = find 'td#request_list_cell'
    if omniture_node
      omniture_text = omniture_node.text
    else
      omniture_text = nil
    end
  end

  @driver.switch_to.window original_window
  omniture_text
end

def visit(url)
  begin
    Timeout::timeout(5) do
      @driver.navigate.to url 
    end
  rescue Timeout::Error, Net::ReadTimeout
  end
  wait_for_page_to_load
end

def evaluate_script(script)
  begin
    @driver.execute_script "return #{script}"
  rescue Selenium::WebDriver::Error::JavascriptError
    "javascript error"
  end
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