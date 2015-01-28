require_relative '../minitest_helper' 
  
class BWSearchTest < MiniTest::Test
  context "a search query" do 
    setup do 
      firefox
      visit "#{BW_BASE_URL}"
    end

    should "produce results" do
      element = @driver.find_element(:css, "#show_searchform")
      element.click
      search_form = @driver.find_element(:css, "#edit-search-block-form--2")
      search_form.send_keys "exercise"
      search_form.submit
      wait_for_page_to_load
      assert_equal(true, (@driver.find_elements(:css, "#block-system-main > div > section > div.article_listing_list > ul > li > article > div > h2 > a").length) >= 1)
    end
  end#a search query

  def teardown  
    @driver.quit 
  end 
end