require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/phase_page'

class DecreasedSmellAndTastePageTest < MiniTest::Test
  context "ibd introduction" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/phases.yml')
      fixture           = YAML::load_documents(io)
      phase_fixture     = OpenStruct.new(fixture[0]['ibd_introduction'])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Digestive Health",
                                   :related => ['Acid Refulx'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = ::Phases::PhasePage.new(:driver => @driver,:proxy => @proxy,:fixture => phase_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/ibd/d/introduction"
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
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal("Inflammatory Bowel Disease | www.healthcentral.com", @driver.title)
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site           = 'cm.ver.ibd'
        ad_categories     = ["", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = ""
        thcn_super_cat    = "Body & Mind"
        thcn_category     = "Digestive Health"
        ads                     = Phases::PhasePage::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => "#{HC_BASE_URL}/ibd/d/introduction",
                                                                     :ad_site => ad_site,
                                                                     :ad_categories => ad_categories,
                                                                     :exclusion_cat => exclusion_cat,
                                                                     :sponsor_kw  => sponsor_kw,
                                                                     :thcn_content_type => thcn_content_type,
                                                                     :thcn_super_cat => thcn_super_cat,
                                                                     :thcn_category => thcn_category,
                                                                     :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture
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
    @driver.quit  
    @proxy.close
  end 
end