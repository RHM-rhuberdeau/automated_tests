require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_question_page'

class SkinCareQuestionPageTest < MiniTest::Test
  context "a question with lots of community answers" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][132858])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Skin Care",
                                   :related => ['Skin Cancer'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = RedesignQuestion::RedesignQuestionPage.new(:driver => @driver ,:proxy => @proxy,:fixture => @question_fixture, :head_navigation => head_navigation, :footer => footer)
      @url  = "#{HC_BASE_URL}/skin-care/c/question/550423/132858" + $_cache_buster
      visit @url
    end

    # ##################################################################
    # ################ FUNCTIONALITY ###################################
    # context "when functioning properly" do 
    #   should "not have any errors" do 
    #     functionality = @page.functionality(:driver => @driver, :phase => "introduction", :phase_navigation => ['Introduction', 'Diagnosis', '', 'Living With', 'Treatment', 'Care', 'Related Conditions'])
    #     functionality.validate
    #     assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
    #   end
    # end

    ##################################################################
    ################### SEO ##########################################
    context "SEO safe" do 
      should "have the correct title" do 
        seo = @page.seo(:driver => @driver) 
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
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

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe   = true
        has_file      = @page.analytics_file
        ad_site       = "cm.ver.skin"
        ad_categories = ["skinhealth","acne",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "Questions",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Skin Health",
                                                           :ugc => "n") 
        ads.validate

        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global site requirements" do 
      should "have passing global test cases" do 
        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

        subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
        title_link = @driver.find_element(:css, ".Page-category-titleLink")
        sub_category_links = @driver.find_element(:link, "Skin Cancer")
      end
    end
  end

  def teardown  
    cleanup_driver_and_proxy
  end 
end