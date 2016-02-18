require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_mobile_page'

class HypothyroidismMobile < MiniTest::Test
  context "a mobile custom program" do 
    setup do 
      capybara_with_phantomjs_mobile
      io                = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture     = YAML::load_documents(io)
      @entry_fixture    = OpenStruct.new(entry_fixture[0]['hypothyroidism_mobile'])
      head_navigation   = HealthCentralHeader::CustomProgramHeader.new(:driver => @driver, :subject => "Living with Hypothyroidism")
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = RedesignEntry::RedesignEntryMobilePage.new(:driver => @driver,:proxy => @proxy,:fixture => @entry_fixture, :head_navigation => head_navigation, :footer => footer)
      @url              = "#{HC_BASE_URL}/more-conditions/c/174035/177245/hypothyroidism/" + $_cache_buster
      visit @url
      wait_for { has_selector?("h1.Page-info-title", :visible => true) }
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:author_name => "Yumhee Park", :author_role => "Editor", :nofollow_author_links => false, :profile_link => "#{HC_BASE_URL}/profiles/c/174035")
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
        omniture  = @page.omniture(:url => @url)
        omniture.validate
        ads       = RedesignEntry::RedesignEntryPage::LazyLoadedAds.new(:driver => @driver,
                                                             :proxy => @proxy, 
                                                             :ad_site => 'cm.own.tcc',
                                                             :ad_categories => ["synthroid","",""],
                                                             :exclusion_cat => "",
                                                             :sponsor_kw  => "",
                                                             :thcn_content_type => "SharePosts",
                                                             :thcn_super_cat => "Healthy Living",
                                                             :thcn_category => "Diet and Fitness",
                                                             :ugc => "n",
                                                             :trigger_point => ".Ad.Ad--bigbox-blogpost.Ad--blogpost.js-Blogpost-ad-inside") 
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
    cleanup_capybara
  end 
end