require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'

class SlideshowTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
    end

    should "update the ads between each slide" do 
      visit "#{HC_BASE_URL}/multiple-sclerosis/cf/slideshows/top-ten-common-myths-about-ms-busted"
      @page.go_through_slide_show
      assert_equal(true, @page.has_unique_ads?)
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end