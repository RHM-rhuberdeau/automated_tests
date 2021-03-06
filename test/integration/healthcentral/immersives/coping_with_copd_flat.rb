require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/immersive_flat_page'

class ImmersiveFlatPageTest < MiniTest::Test
  context "ibd introduction" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/topics.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['ibd_symptoms'])
      head_navigation   = HealthCentralHeader::ImmersiveFlatHeader.new(:title => "Living with COPD: Turning Points", 
                                   :sub_category => "COPD",
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = Immersives::ImmersivePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "http://immersive.healthcentral.com/copd/d/lbln/living-with-copd-mark/flat/"
    end

    # ##################################################################
    # ################ FUNCTIONALITY ###################################
    # context "when functioning properly" do 
    #   should "not have any errors" do 
    #     functionality = @page.functionality(:driver => @driver, :phase => "Symptoms", :phase_navigation => ['Introduction', 'Diagnosis', '', 'Living With', 'Treatment', 'Care', 'Related Conditions'])
    #     functionality.validate
    #     assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
    #   end
    # end

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    # ##################################################################
    # ################### SEO ##########################################
    # context "SEO" do 
    #   should "have the correct title" do 
    #     assert_equal("Symptoms - Digestive Health | www.healthcentral.com", @driver.title)
    #   end
    # end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    # context "ads, analytics, omniture" do
    #   should "not have any errors" do 
    #     ad_site           = 'cm.ver.ibd'
    #     ad_categories     = ["introduction", "symptoms", '']
    #     exclusion_cat     = ""
    #     sponsor_kw        = ''
    #     thcn_content_type = "topic"
    #     thcn_super_cat    = "Body & Mind"
    #     thcn_category     = "Digestive Health"
    #     ads                     = Topics::TopicPage::AdsTestCases.new(:driver => @driver,
    #                                                                  :proxy => @proxy, 
    #                                                                  :url => "http://immersive.healthcentral.com/copd/d/lbln/living-with-copd-mark/flat/",
    #                                                                  :ad_site => ad_site,
    #                                                                  :ad_categories => ad_categories,
    #                                                                  :exclusion_cat => exclusion_cat,
    #                                                                  :sponsor_kw  => sponsor_kw,
    #                                                                  :thcn_content_type => thcn_content_type,
    #                                                                  :thcn_super_cat => thcn_super_cat,
    #                                                                  :thcn_category => thcn_category,
    #                                                                  :ugc => "[\"n\"]") 
    #     ads.validate

    #     omniture = @page.omniture(:url => @url)
    #     omniture.validate
    #     assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
    #   end
    # end

    # ##################################################################
    # ################### GLOBAL SITE TESTS ############################
    # context "Global Site tests" do 
    #   should "have passing global test cases" do 
    #     global_test_cases = @page.global_test_cases
    #     global_test_cases.validate
    #     assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
    #   end
    # end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end