require_relative '../../minitest_helper' 

class LoginTest < MiniTest::Test
  context "Logging in on drupal" do
    setup do
      firefox
      visit HC_BASE_URL
    end

    should "show the user display name" do
      login_link = @driver.find_element(:css, "a.hcnLogin")
      login_link.click
      Selenium::WebDriver::Wait.new { @driver.find_element(:css, "div.gigya-screen-dialog-inner") }
      email    = @driver.find_elements(:css, ".gigya-composite-control-textbox.gigya-input-wrapper .gigya-input-text").select { |element| element.displayed? }.first
      password = @driver.find_elements(:css, ".gigya-input-password").select { |element| element.displayed? }.first
      submit   = @driver.find_elements(:css, ".gigya-input-submit").select { |element| element.displayed? }.first

      email.click
      email.send_keys("rhuberdeau@remedyhealthmedia.com")
      password.click
      password.send_keys("aaaaaa")
      submit.click
      gigya_box = @driver.find_element(:css, "div.gigya-screen-dialog-inner")
      modal     = @driver.find_element(:css, "div.gigya-overlay")
      Selenium::WebDriver::Wait.new { !gigya_box.displayed? }
      Selenium::WebDriver::Wait.new { !modal.displayed? }
      sleep 1

      Selenium::WebDriver::Wait.new { @driver.find_element(:css, "div.HC-header-registration") }
      login    = @driver.find_element(:css, "div#HCN-display-name")
      assert_equal(false, login.nil?)
      assert_equal("rhuberdeau", login.text)
    end

    # should "not produce a login loop" do 
    #   @driver.manage.delete_all_cookies
    #   @driver.manage.add_cookie(:name => 'weblog_data', :value => '---+%7B%7D%0A%0A')
    #   @driver.manage.add_cookie(:name => 'w_id', :value => '272624')
    #   @driver.manage.add_cookie(:name => 'uvts', :value => '25IFHbr4enWslzRO')
    #   @driver.manage.add_cookie(:name => 'u_id', :value => '227165')
    #   @driver.manage.add_cookie(:name => 'membervert', :value => '')
    #   @driver.manage.add_cookie(:name => 'memberticket', :value => '893b3a8e06d4cca951d469558f77d3ff')
    #   @driver.manage.add_cookie(:name => 'hc_uid', :value => '558c484a5baa4fb9b375a493c6198556')
    #   @driver.manage.add_cookie(:name => 'has_js', :value => '1')
    #   @driver.manage.add_cookie(:name => 'display_name', :value => 'Nikki+Cagle')
    #   @driver.manage.add_cookie(:name => '_blogs_session', :value => 'BAh7CDoMcmVmZXJlciIzaHR0cDovL3d3dy5oZWFsdGhjZW50cmFsLmNvbS9kaWFiZXRlcy9jL2NyZWF0ZToPc2Vzc2lvbl9pZCIlNDBiYTk5Nzg5ZjIyYzUxM2Q2ZGIzMzJlYzc5MjFhMzE6EF9jc3JmX3Rva2VuIjFPejVNajU5amJRdWl5Sk1VeTBEdXllWEdoa1lTTElxRDNncWg5SG5DZmdFPQ%3D%3D--798bc2d268efb4b2b2166ed0d33cab4c1af923f4')
    #   sleep 0.5

    #   visit "http://www.healthcentral.com/adhd/c/question/820689/174353"
    #   Selenium::WebDriver::Wait.new { @driver.find_element(:css, "div.HC-header-registration") }
    #   login    = @driver.find_element(:css, "div#HCN-display-name")
    #   assert_equal(false, login.nil?)
    #   assert_equal("rhuberdeau", login.text)

    #   cookies = @driver.manage.all_cookies
    #   puts "Cookies: #{cookies.inspect}"
    # end
  end
  def teardown  
    @driver.quit  
  end  
end