require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/dailydose_page'

class DailyDoseHomePage < MiniTest::Test
  context "daily dose homepage" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/daily_dose.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['watson_mobile'])
      head_navigation   = HealthCentralHeader::DailyDoseMobile.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = DailyDose::DailyDosePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/dailydose/watson_supercomputer_to_guide_personalized_cancer_treatments"
    end

    # ##################################################################
    # ################ FUNCTIONALITY ###################################
    # context "when functioning properly" do 
    #   should "not have any errors" do 
    #     quote_of_the_day = find "p.js-fake-infinite-title-green"
    #     quote_text       = quote_of_the_day.text if quote_of_the_day
    #     infite_content   = @driver.find_elements(:css, ".js-fake-infinite-content") || []
    #     if infite_content
    #       infite_content = infite_content.select {|x| x.displayed?}
    #     end
    #     inside_dailydose = find "div.js-TrackingInternal--mpop h2"
    #     inside_dd_text   = inside_dailydose.text if inside_dailydose

    #     scroll_to_bottom_of_page

    #     new_content_count = @driver.find_elements(:css, ".js-fake-infinite-content")
    #     sleep 0.5


    #     assert_equal(false, quote_text.nil?)
    #     assert_equal(true, quote_text.length > 1)
    #     assert_equal(1, infite_content.length)
    #     assert_equal(true, infite_content.length < new_content_count.length, "page failed to lazy load additional content")
    #     assert_equal(11, new_content_count.length)
    #   end
    # end

    # ##################################################################
    # ################### ASSETS #######################################
    # context "assets" do 
    #   should "have valid assets" do 
    #     assets = @page.assets
    #     assets.validate
    #     assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
    #   end
    # end

    # ##################################################################
    # ################### SEO ##########################################
    # context "SEO" do 
    #   should "have the correct title" do 
    #     assert_equal("\"Watson\" supercomputer to guide personalized cancer treatments", @driver.title)
    #   end
    # end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site           = 'cm.ver.dailydose'
        ad_categories     = ["general", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "dailydose"
        thcn_super_cat    = "HealthCentral"
        thcn_category     = ""
        ads               = DailyDose::DailyDosePage::LazyLoadedAds.new(:driver => @driver,
                                                                        :proxy => @proxy, 
                                                                        :url => "#{HC_BASE_URL}/dailydose/watson_supercomputer_to_guide_personalized_cancer_treatments",
                                                                        :ad_site => ad_site,
                                                                        :ad_categories => ad_categories,
                                                                        :exclusion_cat => exclusion_cat,
                                                                        :sponsor_kw  => sponsor_kw,
                                                                        :thcn_content_type => thcn_content_type,
                                                                        :thcn_super_cat => thcn_super_cat,
                                                                        :thcn_category => thcn_category,
                                                                        :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

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