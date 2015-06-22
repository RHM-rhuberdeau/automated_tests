require 'selenium-webdriver'
require 'rspec/expectations'
include RSpec::Matchers

def setup
  @driver = Selenium::WebDriver.for :remote, url: 'http://localhost:8001'
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
  failed_pages = []
  file = File.open('urls.txt')
  file.each_line do |line|
    puts line
    begin
      @driver.get line.strip
    rescue Net::ReadTimeout
    end
    defined = @driver.execute_script "typeof AD_CATEGORIES != 'undefined'"
    if defined == true
      categories = @driver.execute_script "return AD_CATEGORIES"
      categories = categories.reject { |c| c.empty? }
    else 
      categories = []
    end
    if categories.length < 2
      failed_pages << line 
    end
  end
  expect(failed_pages).to be_empty, "expected empty array, got #{failed_pages.inspect}"

  # should "have ad categories" do 
  #   failed_pages = []
  #   file = File.open('urls.txt')
  #   file.each_line do |line|
  #     visit line.strip
  #     wait_for { @driver.find_element(:css, "#slide-1").displayed? }
  #     defined = @driver.execute_script "return typeof AD_CATEGORIES != 'undefined'"
  #     if defined == (true || 'true')
  #       categories = @driver.execute_script "return AD_CATEGORIES"
  #       categories = categories.reject { |c| c.empty? }
  #     else 
  #       categories = []
  #     end
  #     if categories.length < 2
  #       failed_pages << line 
  #     end
  #   end
  #   assert_equal(true, failed_pages.empty?, "expected empty array, got #{failed_pages.inspect}")
  # end
end