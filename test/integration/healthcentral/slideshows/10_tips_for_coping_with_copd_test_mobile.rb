require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/mobile_slideshow'

class SlideshowTest < MiniTest::Test
  context "a mobile slideshow in a collection, coping with copd" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      head_navigation = HealthCentralHeader::LBLNMobile.new(:logo => "#{ASSET_HOST}com/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :title_link => "Living Well with COPD",
                                   :more_on_link => "more on COPD »",
                                   :driver => @driver)
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::HealthCentralMobileSlideshow::MobileSlideshowPage.new(:driver => @driver, :proxy => @proxy, :head_navigation => head_navigation, :footer => footer, :collection => true)
      visit "#{HC_BASE_URL}/copd/cf/slideshows/10-tips-for-coping-with-copd"
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

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      should "have passing global test cases" do 
        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end