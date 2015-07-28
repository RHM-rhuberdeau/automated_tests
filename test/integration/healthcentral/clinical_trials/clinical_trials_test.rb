require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class ClinicalTrials < MiniTest::Test
  context "living with ra" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/clinical_trials.yml')
      trial_fixture = YAML::load_documents(io)
      @trial_fixture = OpenStruct.new(trial_fixture[0]['clinical_trials'])
      head_navigation   = HealthCentralHeader::ClinicalTrialHeader.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::RedesignEntry::RedesignEntryPage.new(:driver =>@driver, :proxy => @proxy, :fixture => @trial_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url  = "#{HC_BASE_URL}/tools/d/clinical-trials"
      visit @url
    end

    ##################################################################
    ################### ASSETS #######################################
    context "assets safe" do 
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
        assert_equal(true, @page.has_correct_title?)
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site                 = "cm.ver.dacprs"
        ads                     = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => "#{HC_BASE_URL}/tools/d/clinical-trials",
                                                                     :ad_site => ad_site,
                                                                     :ad_categories => ["","",""],
                                                                     :exclusion_cat => "",
                                                                     :sponsor_kw => '',
                                                                     :thcn_content_type => "Umbrella Center",
                                                                     :thcn_super_cat => "HealthCentral",
                                                                     :thcn_category => " ",
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