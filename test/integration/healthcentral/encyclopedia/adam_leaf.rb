require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/encyclopedia_page'

class AdamLeafTest < MiniTest::Test
  include Capybara::DSL

  context "An Adams leaf page, ADHD" do 
    setup do 
      capybara_with_phantomjs
      @driver         = Capybara.current_session
      io              = File.open('test/fixtures/healthcentral/encyclopedia.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['adam_leaf_adhd'])
      head_navigation = HealthCentralHeader::RedesignHeader.new(:driver => @driver, :sub_category => "ADHD", :related => ['Depression', 'Anxiety', 'Autism'])
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page           = ::HealthCentralEncyclopedia::EncyclopediaPage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url            = "#{HC_BASE_URL}/adhd/encyclopedia/" + $_cache_buster
      preload_page @url
      visit @url
      wait_for {find("h1.Page-info-title").visible?}
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "have the proper links" do 
        condition           = find "h1.Page-info-title"
        condition           = condition.text if condition
        condition_links     = all(:css, "ul.ContentList li a")
        anchor_links        = all('a[rel="canonical"]', :visible => false)
        link_tags           = all('link[rel="canonical"]', :visible => false)
        all_links           = anchor_links.to_a + link_tags.to_a
        all_hrefs           = all_links.collect { |l| l[:href]}.compact

        all_hrefs.each do |link|
          assert_equal(true, @url.include?(link))
        end
        assert_equal("ADHD Index", condition)
        assert_equal(4, condition_links.length)
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
        ad_site       = "cm.ver.adhd"
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
                                                           :thcn_category => "Mental Health",
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