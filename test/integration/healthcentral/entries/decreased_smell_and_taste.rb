require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class DecreasedSmellAndTastePageTest < MiniTest::Test
  context "a health pro member entry" do 
    setup do 
      capybara_with_phantomjs
      io                = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture     = YAML::load_documents(io)
      @entry_fixture    = OpenStruct.new(entry_fixture[0][173667])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Allergy",
                                   :related => ['Asthma', 'Cold & Flu', 'Skin Care'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::RedesignEntry::RedesignEntryPage.new(:driver => @driver,:proxy => @proxy,:fixture => @entry_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url  = "#{HC_BASE_URL}/allergy/c/3989/173667/decreased-common-bedfellows" + $_cache_buster
      visit @url
      wait_for { has_selector?("h1.Page-info-title", :visible => true) }
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:author_name => "James Thompson, MD", :author_role => "Health Pro", :nofollow_author_links => false, :profile_link => "#{HC_BASE_URL}/profiles/c/3989")
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
        pharma_safe   = true
        has_file      = @page.analytics_file
        ad_site       = "cm.ver.allergy"
        ad_categories = ["allergy","",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "SharePosts",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Allergies",
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
    Capybara.reset_sessions!
  end 
end