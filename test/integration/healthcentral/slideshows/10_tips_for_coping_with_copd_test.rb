require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/slideshow'

class SlideshowTest < MiniTest::Test
  context "a slideshow in a collection, coping with copd" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/slideshows.yml')
      slideshow_fixture = YAML::load_documents(io)
      @fixture = OpenStruct.new(slideshow_fixture[0]['copd'])
      head_navigation = HealthCentralHeader::LBLNDesktop.new(:logo => "#{ASSET_HOST}com/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :title_link => "Living Well with COPD",
                                   :more_on_link => "more on COPD »",
                                   :sub_category => "Multiple Sclerosis",
                                   :related => ['Chronic Pain', 'Depression', 'Rheumatoid Arthritis'],
                                   :driver => @driver)
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::HealthCentralSlideshow::SlideshowPage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture, :head_navigation => head_navigation, :footer => footer, :collection => true)
      @url  = "#{HC_BASE_URL}/copd/cf/slideshows/10-tips-for-coping-with-copd" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
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
        assets = @page.assets(:base_url => @url)
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO safe" do 
      should "have the correct title" do 
        seo = @page.seo(:driver => @driver) 
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "omniture" do
      should "not have any errors" do 
        ad_site        = "cm.ver.lblnstopsmoking"
        ad_categories  = ["slideshow", "copingwithcopd", ""]
        ads_test_cases = @page.ads_test_cases(:ad_site => ad_site, :ad_categories => ad_categories)
        omniture       = @page.omniture(:url => @url)

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