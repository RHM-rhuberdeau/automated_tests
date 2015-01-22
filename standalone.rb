require 'selenium-webdriver'
require 'rspec-expectations'
require 'browsermob/proxy'
include RSpec::Matchers

def setup
  @driver = Selenium::WebDriver.for :firefox
  @driver.manage.window.resize_to(1024,728)
  @driver.manage.timeouts.implicit_wait = 5
end

def teardown
  @driver.quit
end

def run
  setup
  yield
  teardown
end

run do
  @driver.get 'http://the-internet.herokuapp.com'
  expect(@driver.title).to eq('The Internet')
end