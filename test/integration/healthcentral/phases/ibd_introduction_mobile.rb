require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/phase_mobile_page'

class MobileIBDIntroductionTest < MiniTest::Test
  context "mobile ibd introduction" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/phases.yml')
      fixture           = YAML::load_documents(io)
      phase_fixture     = OpenStruct.new(fixture[0]['mobile_ibd_introduction'])
      head_navigation   = HealthCentralHeader::MobileRedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Digestive Health",
                                   :related_links => ['Acid Reflux'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = Phases::MobilePhasePage.new(:driver => @driver,:proxy => @proxy,:fixture => phase_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/ibd/d/introduction" + $_cache_buster
      visit @url
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:driver => @driver, :phase => "introduction", :phase_navigation => ['Introduction', 'Diagnosis', '', 'Living With', 'Treatment', 'Care', 'Related Conditions'])
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
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site           = 'cm.ver.ibd'
        ad_categories     = ["introduction", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "phase"
        thcn_super_cat    = "Body & Mind"
        thcn_category     = "Digestive Health"
        ads               = Phases::MobilePhasePage::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => @url,
                                                                     :ad_site => ad_site,
                                                                     :ad_categories => ad_categories,
                                                                     :exclusion_cat => exclusion_cat,
                                                                     :sponsor_kw  => sponsor_kw,
                                                                     :thcn_content_type => thcn_content_type,
                                                                     :thcn_super_cat => thcn_super_cat,
                                                                     :thcn_category => thcn_category,
                                                                     :ugc => "n") 
        ads.validate

        omniture = @page.omniture(:url => @url)

        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
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
    cleanup_driver_and_proxy
  end 
end