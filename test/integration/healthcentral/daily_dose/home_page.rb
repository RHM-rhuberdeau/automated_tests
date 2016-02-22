require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/dailydose_page'

class DailyDoseHomePage < MiniTest::Test
  include Capybara::DSL

  context "daily dose homepage" do 
    setup do 
      capybara_with_phantomjs
      @driver           = Capybara.current_session
      io                = File.open('test/fixtures/healthcentral/daily_dose.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['home'])
      head_navigation   = HealthCentralHeader::DailyDoseDesktop.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = DailyDose::DailyDosePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/dailydose/" + $_cache_buster
      preload_page @url
      visit @url
      wait_for { find("p.js-fake-infinite-title-desc").visible? }
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        headers           = all(:css, "h2")
        header_text       = headers.collect(&:text).compact
        infite_content    = all(:css, ".js-fake-infinite-content") || []

        if infite_content
          infite_content  = infite_content.select {|x| x.visible?}
        end

        scroll_to_bottom_of_page
        sleep 0.5
        new_content       = all(:css, ".js-fake-infinite-content")
        if new_content
          new_content     = new_content.select {|x| x.visible?}
        end

        assert_equal(false, header_text.nil?, "header text was nil")
        assert_equal(true, header_text.length == headers.length, "A h2 tag was blank")
        assert_equal(1, infite_content.length, "no infinite content on the page")
        assert_equal(true, infite_content.length < new_content.length, "page failed to lazy load additional content")
        assert_equal(true, new_content.length > 0, "no new content was lazy loaded")
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
        ad_site           = 'cm.ver.dailydose'
        ad_categories     = ["general", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "dailydose"
        thcn_super_cat    = "HealthCentral"
        thcn_category     = ""
        ads               = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                              :proxy => @proxy, 
                                                              :url => @url,
                                                              :ad_site => ad_site,
                                                              :ad_categories => ad_categories,
                                                              :exclusion_cat => exclusion_cat,
                                                              :sponsor_kw  => sponsor_kw,
                                                              :thcn_content_type => thcn_content_type,
                                                              :thcn_super_cat => thcn_super_cat,
                                                              :thcn_category => thcn_category,
                                                              :ugc => "n") 
        ads.validate

        omniture = @page.omniture
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