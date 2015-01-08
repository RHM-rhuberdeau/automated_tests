# require 'capybara'
# require 'capybara/dsl'

# Capybara.run_server = false
# Capybara.current_driver = :selenium
# Capybara.app_host = 'http://www.google.com'

# module MyCapybaraTest
#   class Test
#     include Capybara::DSL
#     def test_google
#       visit('/')
#     end
#   end
# end

# t = MyCapybaraTest::Test.new
# t.test_google

require 'rubygems'  
require 'minitest/autorun'  
require 'selenium-webdriver'  
  
class GoogleTest < MiniTest::Test  
  def setup  
    @driver = Selenium::WebDriver.for :firefox
    #@driver.manage.window.maximize
    #puts @driver.manage.window.size
    @driver.navigate.to  'http://www.google.com'
  end  
  
  def test_post  
    @driver.navigate.to "http://www.google.com"  
    element = @driver.find_element(:name, 'q')  
    element.send_keys "TestingBot"  
    element.submit  
    assert_equal("TestingBot - Google Search", @driver.title)  
  end  
  
  def teardown  
    @driver.quit  
  end  
end 