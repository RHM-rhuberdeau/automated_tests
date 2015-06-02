ENV['SAUCE_USERNAME'] = 'rhuberdeau2'
ENV['SAUCE_API_KEY']  = '6e4a81ea-50c2-40ba-a009-00e113f99e7a'

require 'selenium-webdriver'
require 'rspec/expectations'

def setup(browser_name, browser_version)
  caps = Selenium::WebDriver::Remote::Capabilities.send(browser_name.to_sym)
  caps.platform = 'Windows XP'
  caps.version = browser_version.to_s

  Thread.current[:driver] = Selenium::WebDriver.for(
    :remote,
    url: "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_API_KEY']}@ondemand.saucelabs.com:80/wd/hub",
    desired_capabilities: caps)
end

def teardown
  Thread.current[:driver].quit
end


BROWSERS = { firefox: '27',
             chrome: '32',
             internet_explorer: '8' }

def run
  threads = []
  BROWSERS.each_pair do |browser, browser_version|
    threads << Thread.new do
      setup(browser, browser_version)
      yield
      teardown
    end
  end
  threads.each { |thread| thread.join }
end

run do
  Thread.current[:driver].get 'http://qa1.healthcentral.com'
  Thread.current[:driver].title.should == 'HealthCentral.com - Trusted, Reliable and Up To Date Health Information'
end