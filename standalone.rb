require 'selenium-webdriver'
require 'rspec/expectations'
require 'capybara'
require 'capybara/dsl'
require 'browsermob/proxy'

server = BrowserMob::Proxy::Server.new('/Users/rhuberdeau/Downloads/browsermob-proxy-2.0-beta-9/bin/browsermob-proxy')
server.start
@proxy = server.create_proxy
@profile = Selenium::WebDriver::Firefox::Profile.new
@profile.proxy = @proxy.selenium_proxy

Capybara.run_server = false
Capybara.default_driver = :selenium
Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :profile => @profile)
end

module StandAlone
  class Test
  	include Capybara::DSL

  	def setup
  	  #@driver = Selenium::WebDriver.for :remote, url: 'http://localhost:9515', desired_capabilities: :chrome
  	end

  	def teardown
  	  #@driver.quit
  	end

  	def run
  	  setup
  	  run_tests
  	  teardown
  	end

  	def run_tests
  	  visit "http://www.berkeleywellness.com/healthy-eating/food/slideshow/can-food-cause-body-odor"

  	  wait_for_ajax

  	  slideshow = page.all("ul.slides").first
  	  slides    = slideshow.all('li', visible: false)
  	  slides.each_with_index do |slide, index|
  	    unless index == 6
  	      text = slide.text
  	      page.find("a.flex-next").click
  	      wait_for_ajax
  	      slideshow.text.should_not == text
  	    end
  	  end

  	  slides = slides.to_a.reverse
  	  slides.each_with_index do |slide, index|
  	    unless index == 6
  	      text = slide.text
  	      page.find("a.flex-prev").click
  	      wait_for_ajax
  	      slideshow.text.should_not == text
  	    end
  	  end
  	end

  	def wait_for_ajax
      Timeout.timeout(Capybara.default_wait_time) do
        loop until finished_all_ajax_requests?
      end
  	end

  	def finished_all_ajax_requests?
  	  page.evaluate_script('jQuery.active').zero?
  	  sleep 0.5
  	end
  end
end
# class SlideShow
#   require 'rspec-expectations'

#   attr_reader :driver, :failed_slides

#   def initialize(driver)
#   	@driver = driver
#   	@failed_slides = 0
#   	visit
#   	verify_page
#   end

#   def visit 
#   	driver.get "http://www.berkeleywellness.com/healthy-eating/food/slideshow/can-food-cause-body-odor"
#   end

#   def browse_slides
#   	# @slideshow = page.all("ul.slides").first
#   	# @slides    = @slideshow.all('li', visible: false)
#   	# @slides.each_with_index do |slide, index|
#   	#   unless index == 6
#   	#     text = slide.text
#   	#     page.find("a.flex-next").click
#   	#     wait_for_ajax
#   	#     expect(@slideshow.text).to_not eq(text)
#   	#   end
#   	# end
#   	slideshow = driver.find_elements(css: 'ul.slides')
#   	slides = slideshow.find_elements
#   end

#   private

#     def verify_page
#       driver.title.include?("Can Food Cause Body Odor?").should == (true)
#     end
# end


# run {
#   slide_show = SlideShow.new(@driver)
#   slide_show.browse_slides
#   #expect(slide_show.failed_slides).to equal(0)
#   slide_show.failed_slides.should == (0)
# }
test = StandAlone::Test.new
test.run_tests