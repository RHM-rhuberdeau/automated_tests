require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/encyclopedia_page'

class HcArticlePage < MiniTest::Test
  context "HC Encyclopedia article, Autologous Blood Donation" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/encyclopedia.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['hc_article'])
      head_navigation = HealthCentralHeader::EncyclopediaDesktop.new(:driver => @driver)
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page           = ::HealthCentralEncyclopedia::EncyclopediaPage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url            = "#{HC_BASE_URL}/encyclopedia/hc/autologous-blood-donation-3168430/"
      visit "#{@url}#{$_cache_buster}"
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "have the proper links" do 
        condition    = find "h1.Page-info-title"
        condition    = condition.text if condition
        content      = find "ul.ContentList.ContentList--article"
        bread_crumbs = @driver.find_elements(:css, "div.Breadcrums-container a") || []
        anchor_links  = @driver.find_elements(:css, "a").select { |x| x.attribute('rel') == "canonical" }.compact
        link_tags     = @driver.find_elements(:css, "link").select { |x| x.attribute('rel') == "canonical" }.compact
        all_links     = anchor_links + link_tags
        all_hrefs     = all_links.collect { |l| l.attribute('href')}.compact

        all_hrefs.each do |link|
          assert_equal(true, link.include?(@url))
        end

        if content
          content = content.text
        else
          content = ""
        end
        assert_equal("Autologous Blood Donation", condition)
        assert_equal(true, content.length > 300)
        assert_equal(2, bread_crumbs.length)
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
        ad_site       = "cm.own.healthcentral"
        ad_categories = ["encyclopedia-index","encyclopedia",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "encyclopedia",
                                                           :thcn_super_cat => "HealthCentral",
                                                           :thcn_category => "",
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