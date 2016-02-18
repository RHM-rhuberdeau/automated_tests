require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationPageTest < MiniTest::Test
  context "acid reducer" do 
    setup do 
      capybara_with_phantomjs
      io                = File.open('test/fixtures/healthcentral/fdb.yml')
      fixture           = YAML::load_documents(io)
      fdb_fixture       = OpenStruct.new(fixture[0]['acid_reducer'])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Acid Reflux",
                                   :related => ['Digestive Health'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = FDB::FDBPage.new(:driver => @driver,:proxy => @proxy,:fixture => fdb_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/acid-reflux/medications/acid-reducer-famotidine-oral-153189/" + $_cache_buster
      preload_page @url
      visit @url
      wait_for { find("h1.Page-info-title").visible? }
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
        ad_site           = 'cm.ver.acidreflux'
        ad_categories     = ["medications", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "Drug"
        thcn_super_cat    = "Body & Mind"
        thcn_category     = "Digestive Health"
        omniture          = @page.omniture(:url => @url)
        ads               = HealthCentralAds::AdsTestCases.new(:driver => @driver,
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
    cleanup_capybara
  end 
end