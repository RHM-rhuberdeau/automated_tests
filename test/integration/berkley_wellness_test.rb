require_relative '../minitest_helper' 

class BerkleyWellnessTest < MiniTest::Test
  context "Berkley Wellness" do 
    setup do 
      firefox
      visit BW_BASE_URL
    end

    should "have a working search" do 
      element = @driver.find_element(:css, "#show_searchform")
      element.click
      search_form = @driver.find_element(:css, "#edit-search-block-form--2")
      search_form.send_keys "exercise"
      search_form.submit
      light_view = @driver.find_element(:css, ".close_lightview")
      if light_view
        light_view.click
      end
      Selenium::WebDriver::Wait.new { !light_view.displayed? }
      assert_equal(true, (@driver.find_elements(:css, "#block-system-main > div > section > div.article_listing_list > ul > li > article > div > h2 > a").length) >= 1)
    end
   
    should "have 'CUSTOMER SERVICE' in the footer" do 
      links = @driver.find_elements(:css, "footer a")  
      link = links.select { |link| link.text == "CUSTOMER SERVICE"}
      assert(true, link.compact.length == 1)
    end

 end#context Berkley Wellness
  def teardown
    @driver.quit
  end
end