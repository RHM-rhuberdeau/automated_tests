require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_mobile_page'

class TurningPointMobileEntryPageTest < MiniTest::Test
  context "an expert entry" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io                = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture     = YAML::load_documents(io)
      @entry_fixture    = OpenStruct.new(entry_fixture[0]['turning_point_mobile'])
      head_navigation   = HealthCentralHeader::MobileRedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Multiple Sclerosis",
                                   :related_links => ['Chronic Pain', 'Depression', 'Rheumatoid Arthritis'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = RedesignEntry::RedesignEntryMobilePage.new(:driver => @driver,:proxy => @proxy,:fixture => @entry_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url  = "#{HC_BASE_URL}/multiple-sclerosis/c/255251/172231/turning-embrace" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:author_name => "JHo", :author_role => "Editor", :nofollow_author_links => true, :profile_link => "#{HC_BASE_URL}/profiles/c/255251")
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
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, @page.has_correct_title?)
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        omniture  = @page.omniture(:url => @url)
        omniture.validate
        ads       = RedesignEntry::RedesignEntryPage::LazyLoadedAds.new(:driver => @driver,
                                                             :proxy => @proxy, 
                                                             :ad_site => 'cm.ver.ms',
                                                             :ad_categories => ['multiplesclerosis','neurology',''],
                                                             :exclusion_cat => "",
                                                             :sponsor_kw  => "",
                                                             :thcn_content_type => "SharePosts",
                                                             :thcn_super_cat => "Body & Mind",
                                                             :thcn_category => "Brain and Nervous System",
                                                             :ugc => "[\"n\"]",
                                                             :trigger_point => "div.ContentListInset.js-content-inset") 
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
    @driver.quit  
    @proxy.close
  end 
end