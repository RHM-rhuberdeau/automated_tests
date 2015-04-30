require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/slideshow'

class SlideshowTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentral::SlideshowPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/multiple-sclerosis/cf/slideshows/top-ten-common-myths-about-ms-busted"
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality
        functionality.validate
        assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
      end
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