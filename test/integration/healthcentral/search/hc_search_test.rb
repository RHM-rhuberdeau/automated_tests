require_relative '../minitest_helper' 
  
class HCSearchTest < MiniTest::Test
  context "a search query" do 
    setup do 
      firefox
      visit "#{HC_BASE_URL}"
    end

    should "produce results" do
      element = @driver.find_element(:css, "#q")
      element.send_keys "diabetes"
      button = @driver.find_element(:css, ".icon-search")
      button.click
      wait_for_page_to_load
      assert_equal("Search Results", (@driver.find_element(:css, 'div.page div.body.portal div.content.results h1')).text)
      assert_equal(true, (@driver.find_elements(:css, "div.page div.body.portal div.content.results ul.results li h3 a").length) >= 1)
    end
  end#a search query

  def teardown  
    @driver.quit 
  end 
end