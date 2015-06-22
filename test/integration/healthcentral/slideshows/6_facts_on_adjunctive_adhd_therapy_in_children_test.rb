require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/slideshow'

class SlideshowTest < MiniTest::Test
  context "6-facts-on-adjunctive-adhd-therapy-in-children" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io                = File.open('test/fixtures/healthcentral/slideshows.yml')
      slideshow_fixture = YAML::load_documents(io)
      @fixture          = OpenStruct.new(slideshow_fixture[0]['adhd_therapy'])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "ADHD",
                                   :related => ['Depression', 'Anxiety', 'Autism'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = ::HealthCentralSlideshow::SlideshowPage.new(:driver => @driver, :fixture => @fixture, :proxy => @proxy, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/adhd/cf/slideshows/6-facts-on-adjunctive-adhd-therapy-in-children"
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

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "omniture" do
      should "not have any errors" do 
        ad_site        = "cm.ver.adhd"
        ad_categories  = ["slideshow", "adjuntiveadhdtherapy", '']
        ads_test_cases = @page.ads_test_cases(:ad_site => ad_site, :ad_categories => ad_categories)
        omniture       = @page.omniture

        wait_for { @driver.find_element(:css, "#slide-1").displayed? }
        ads_test_cases.validate
        omniture.validate
        assert_equal(true, (ads_test_cases.errors.empty? && omniture.errors.empty?), "#{ads_test_cases.errors.messages} #{omniture.errors.messages}")
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