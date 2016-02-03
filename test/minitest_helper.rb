require File.dirname(__FILE__) + '/config/automation_config';
require File.dirname(__FILE__) + '/config/proxy/settings';
require 'minitest/autorun' 
require 'shoulda/context' 
require 'selenium-webdriver' 
require 'browsermob/proxy'
require 'timeout'
require 'minitest/reporters'
require 'capybara/dsl'
require 'capybara/poltergeist'
require 'capybara_minitest_spec'

include Capybara::DSL

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new

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
  
$_cache_buster ||= "?foo=#{rand(36**8).to_s(36)}"

def firefox
  # Selenium::WebDriver::Firefox::Binary.path= '/opt/firefox/firefox'
  # Selenium::WebDriver::Firefox::Binary.path= '/Applications/Firefox.app/Contents/MacOS/firefox'
  @driver = Selenium::WebDriver.for :firefox
  @driver.manage.window.resize_to(1300,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def firefox_with_proxy
  proxy_location = Settings.location
	@server = BrowserMob::Proxy::Server.new(proxy_location)
	@server.start
	@proxy = server.create_proxy
	@profile = Selenium::WebDriver::Firefox::Profile.new
	@profile.proxy = @proxy.selenium_proxy
	@driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(1300,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def fire_fox_with_secure_proxy
  proxy_location = Settings.location
  $_server ||= BrowserMob::Proxy::Server.new(proxy_location).start

  @proxy = $_server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(1300,1000)
  @driver.manage.timeouts.implicit_wait = 3
  @driver.manage.timeouts.page_load = 28
end

def fire_fox_remote_proxy
  $_server ||= BrowserMob::Proxy::Server.new(Settings.location, :opts => { port: 4444, log: true}).start

  @proxy          = $_server.create_proxy
  @profile        = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy  = @proxy.selenium_proxy(:http, :ssl)
  caps = Selenium::WebDriver::Remote::Capabilities.new(
    :browser_name => "firefox", :firefox_profile => @profile
  )
  @driver = Selenium::WebDriver.for(
    :remote,
    url: 'http://localhost:4444/wd/hub',
    desired_capabilities: caps) 
  @driver.manage.window.resize_to(1300,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def mobile_fire_fox_with_secure_proxy
  proxy_location = Settings.location
  $_server ||= BrowserMob::Proxy::Server.new(proxy_location).start
  
  @proxy = $_server.create_proxy
  @profile = Selenium::WebDriver::Firefox::Profile.new
  @profile.proxy = @proxy.selenium_proxy(:http, :ssl)
  @profile['general.useragent.override'] = 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30'
  @driver = Selenium::WebDriver.for :firefox, :profile => @profile
  @driver.manage.window.resize_to(425,960)
  @driver.manage.timeouts.implicit_wait = 5
  @driver.manage.timeouts.page_load = 28
end

def fire_fox_remote
  @driver = Selenium::WebDriver.for(
    :remote,
    url: 'http://localhost:4444/wd/hub',
    desired_capabilities: :firefox)
  @driver.manage.window.resize_to(1300,1000)
  @driver.manage.timeouts.implicit_wait = 5
end

def cleanup_driver_and_proxy
  @driver.quit  
  @proxy.close
end

def cleanup_driver
  @driver.quit
end

def phantomjs
  @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:8001'
end

def capybara_with_phantomjs
  Capybara.register_driver :poltergeist do |app|
      options = {:timeout => 120,
                :phantomjs_options => ['--ignore-ssl-errors=yes'],
                :js_errors => false}
      Capybara::Poltergeist::Driver.new(app, options)
  end

  Capybara.javascript_driver = :poltergeist
  Capybara.default_driver    = :poltergeist
end

# def visit(url)
#   preload_page(url)
#   begin
#     @driver.navigate.to url 
#   rescue Timeout::Error, Net::ReadTimeout, Selenium::WebDriver::Error::TimeOutError
#   end
#   begin
#     @driver.execute_script("window.stop();")
#   rescue Timeout::Error, Net::ReadTimeout, Selenium::WebDriver::Error::JavascriptError
#   end
  
#   #Avoid race conditions
#   sleep 0.25
# end

def preload_page(url)
  if ENV['TEST_ENV'] == "production" || ENV['TEST_ENV'] == "staging"
    begin
      RestClient::Request.execute(method: :get, url: url,
                                timeout: 10)
    rescue RestClient::RequestTimeout, SocketError
    end
  end
end

def wait_for_page_to_load
  begin
    Timeout::timeout(3) do
      loop until finished_loading?
    end
  rescue Timeout::Error, Net::ReadTimeout, EOFError
  end
  sleep 0.5
  begin
    @driver.execute_script("window.stop();")
  rescue Timeout::Error, Net::ReadTimeout
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

def wait_for
  begin
    Selenium::WebDriver::Wait.new(:timeout => 3).until { yield }
  rescue Selenium::WebDriver::Error::NoSuchElementError, Selenium::WebDriver::Error::TimeOutError
    false
  rescue Net::ReadTimeout
    false
  end
end

#Get all network traffic from Phantomjs
def get_network_traffic
  page.driver.network_traffic.map { |request| request.response_parts.uniq(&:url).map { |response| ["#{response.url}", response.status] }}
end

#Looks for a Selenium element with the given css
#Text fails if the element is not on the page, or does not have text
#
# present_with_text?(".content_pad h1")
#
def present_with_text?(css)
  node = find css
  unless node
    self.errors.add(:functionality, "#{css} missing from page")
  end
  if node 
    unless node.text.length > 0
      self.errors.add(:functionality, "#{css} was blank")
    end
  end
end

def scroll_to_bottom_of_page
  @driver.execute_script("window.scrollTo(0,document.body.scrollHeight);")
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

# def evaluate_script(script)
#   begin
#     @driver.execute_script "return #{script}"
#   rescue Selenium::WebDriver::Error::JavascriptError
#     "javascript error"
#   end
# end

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