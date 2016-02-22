require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/encyclopedia_page'

class AdamSubcategoryIndex < MiniTest::Test
  include Capybara::DSL

  context "The adam subcategory index page" do 
    setup do 
      capybara_with_phantomjs
      @driver         = Capybara.current_session
      io              = File.open('test/fixtures/healthcentral/encyclopedia.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['adam_subcategory_index'])
      head_navigation = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Alzheimer's Disease",
                                   :related => ['Depression','Osteoporosis','Menopause'],
                                   :driver => @driver)
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page           = HealthCentralEncyclopedia::EncyclopediaPage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url            = "#{HC_BASE_URL}/alzheimers/encyclopedia/" + $_cache_buster
      preload_page @url
      visit @url
      wait_for { find("h1.Page-info-title").visible? }
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "have the proper links" do 
        conditions_library = find "h1.Page-info-title"
        conditions_library = conditions_library.text if conditions_library
        condition_links    = all(:css, "ul.ContentList li a") || []
        
        assert_equal("Alzheimer's Disease Index", conditions_library)
        assert_equal(14, condition_links.length)
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
        pharma_safe   = true
        ad_site       = "cm.ver.alzheimers"
        ad_categories = ["adam-index","adam",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "adam",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Brain and Nervous System",
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