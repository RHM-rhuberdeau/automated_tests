require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/dailydose_page'

class DailyDoseSugaryDrinks < MiniTest::Test
  context "Sugary drinks dailydose" do 

    setup do 
      capybara_with_phantomjs
      io                = File.open('test/fixtures/healthcentral/daily_dose.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['watson'])
      head_navigation   = HealthCentralHeader::DailyDoseDesktop.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = DailyDose::DailyDosePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/dailydose/2015/6/30/sugary_drinks_tied_to_nearly_200_000_deaths_a_year/" + $_cache_buster
      preload_page @url
      visit @url
      wait_for { find("h1").visible?}
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        quote_of_the_day = all("p.js-fake-infinite-title-green").first
        quote_text       = quote_of_the_day.text if quote_of_the_day
        infite_content   = all(:css, ".js-fake-infinite-content") || []
        anchor_links  = all(:css, "a").select { |x| x[:rel] == "canonical" }.compact
        link_tags     = all('link[rel="canonical"]', :visible => false)
        all_links     = anchor_links.to_a + link_tags.to_a
        all_hrefs     = all_links.collect { |l| l[:href]}.compact

        all_hrefs.each do |link|
          assert_equal(true, @url.include?(link))
        end

        if infite_content
          infite_content = infite_content.select {|x| x.visible?}
        end
        inside_dailydose = find "div.js-TrackingInternal--mpop h2"
        inside_dd_text   = inside_dailydose.text if inside_dailydose

        scroll_to_bottom_of_page
        sleep 0.5
        execute_script("window.scrollTo(0,500);")
        sleep 0.5
        new_content      = all(:css, ".js-fake-infinite-content")
        if new_content
          new_content    = new_content.select {|x| x.visible?}
        end

        assert_equal(false, quote_text.nil?)
        assert_equal(true, quote_text.length > 1)
        assert_equal(1, infite_content.length)
        assert_equal("Inside Today's DOSE", inside_dd_text)
        assert_equal(true, infite_content.length < new_content.length, "page failed to lazy load additional content")
        assert_equal(true, new_content.length >= 2)
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
        assert_equal("Sugary Drinks Tied to Nearly 200,000 Deaths a Year", page.title)
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