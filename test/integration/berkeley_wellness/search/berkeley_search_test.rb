require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/berkeley_slide_show_page'

class BerkeleyTagHomeTest < MiniTest::Test
  context "immune system" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{BW_BASE_URL}"
      @page = ::BerkeleySlideShowPage.new(:driver =>@driver, :proxy => @proxy)
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

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end