require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/berkeley_slide_show_page'

class BerkeleyCategoryHomeTest < MiniTest::Test
  context "supplements vitamins" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{BW_BASE_URL}/supplements/vitamins"
      @page = ::BerkeleySlideShowPage.new(:driver =>@driver, :proxy => @proxy)
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