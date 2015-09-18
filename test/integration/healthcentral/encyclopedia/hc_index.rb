require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/encyclopedia_page'

class HcIndexPage < MiniTest::Test
  context "The encyclopedia index page" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/encyclopedia.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['hc_index'])
      head_navigation = HealthCentralHeader::EncyclopediaDesktop.new(:driver => @driver)
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page           = ::HealthCentralEncyclopedia::EncyclopediaPage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url            = "#{HC_BASE_URL}/encyclopedia/hc/" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
    end

    # ##################################################################
    # ################ FUNCTIONALITY ###################################
    # context "when functioning properly" do 
    #   should "have the proper links" do 
    #     a_to_z_links      = @driver.find_elements(:css, ".ContentList.ContentList--article.js-search-content a")
    #     assert_equal(a_to_z_links.length, 23)
    #   end
    # end

    # ##################################################################
    # ################### ASSETS #######################################
    # context "assets" do 
    #   should "have valid assets" do 
    #     assets = @page.assets(:base_url => @url)
    #     assets.validate
    #     assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
    #   end
    # end

    # ##################################################################
    # ################### SEO ##########################################
    # context "SEO safe" do 
    #   should "have the correct title" do 
    #     seo = @page.seo(:driver => @driver) 
    #     seo.validate
    #     assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
    #   end
    # end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    # context "ads, analytics, omniture" do
    #   should "not have any errors" do 
    #     pharma_safe   = true
    #     ad_site       = "cm.own.healthcentral"
    #     ad_categories = ["encyclopedia-index","encyclopedia",""]
    #     ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
    #                                                        :proxy => @proxy, 
    #                                                        :url => @url,
    #                                                        :ad_site => ad_site,
    #                                                        :ad_categories => ad_categories,
    #                                                        :exclusion_cat => "",
    #                                                        :sponsor_kw => '',
    #                                                        :thcn_content_type => "encyclopedia",
    #                                                        :thcn_super_cat => "",
    #                                                        :thcn_category => "",
    #                                                        :ugc => "[\"n\"]") 
    #     ads.validate

    #     omniture = @page.omniture(:url => @url)
    #     omniture.validate
    #     assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
    #   end
    # end

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