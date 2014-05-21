Capybara.register_driver :iphone do |app| 
  require 'selenium/webdriver' 
  profile = Selenium::WebDriver::Firefox::Profile.new 
  #Change the line below to change the user agent 
  profile['general.useragent.override'] = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A535b Safari/419.3" 
  Capybara::Selenium::Driver.new(app, :profile => profile) 
 end 
 Capybara.use_default_driver 