require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_mobile_page'

class ItMightBeSomethingMobileEntryPageTest < MiniTest::Test
  include Capybara::DSL
  
  context "a community member entry" do 
    setup do 
      capybara_with_phantomjs_mobile
      @driver           = Capybara.current_session
      io                = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture     = YAML::load_documents(io)
      @entry_fixture    = OpenStruct.new(entry_fixture[0]['something_else_mobile'])
      head_navigation   = HealthCentralHeader::MobileRedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Multiple Sclerosis",
                                   :related_links => ['Chronic Pain', 'Depression', 'Rheumatoid Arthritis'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = RedesignEntry::RedesignEntryMobilePage.new(:driver => @driver,:proxy => @proxy,:fixture => @entry_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url  = "#{HC_BASE_URL}/multiple-sclerosis/c/936913/173745/might-something" + $_cache_buster
      visit @url
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:author_name => "robinoakapple1", :author_role => "Community Member", :nofollow_author_links => true, :profile_link => "#{HC_BASE_URL}/profiles/c/936913")
        functionality.validate
        assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
      end
    end

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets(:base_url => @url, :driver => @driver)
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
        omniture  = @page.omniture(:url => @url)
        omniture.validate
        ads       = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                       :proxy => @proxy,
                                                       :url => @url, 
                                                       :ad_site => 'cm.ver.ms',
                                                       :ad_categories => ["multiplesclerosis","whentoseeadoctor",""],
                                                       :exclusion_cat => "community",
                                                       :sponsor_kw  => "",
                                                       :thcn_content_type => "SharePosts",
                                                       :thcn_super_cat => "Body & Mind",
                                                       :thcn_category => "Brain and Nervous System",
                                                       :ugc => "y") 
        ads.validate
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