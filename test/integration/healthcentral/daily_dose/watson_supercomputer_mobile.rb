require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/dailydose_page'

class DailyDoseMobileArticlePage < MiniTest::Test
  context "Mobile sugary drinks dailydose" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io                = File.open('test/fixtures/healthcentral/daily_dose.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['watson_mobile'])
      head_navigation   = HealthCentralHeader::DailyDoseMobile.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = DailyDose::DailyDosePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/dailydose/2015/6/30/sugary_drinks_tied_to_nearly_200_000_deaths_a_year/"
      visit "#{@url}#{$_cache_buster}" 
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        headers           = @driver.find_elements(:css, "h2")
        header_text       = headers.collect(&:text).compact
        article_links     = @driver.find_elements(:css, "ul.ContentList--article li.ContentList-item a") || []
        quote_of_the_day = find "p.js-fake-infinite-title-green"
        quote_text       = quote_of_the_day.text if quote_of_the_day
        infite_content   = @driver.find_elements(:css, ".js-fake-infinite-content") || []
        anchor_links  = @driver.find_elements(:css, "a").select { |x| x.attribute('rel') == "canonical" }.compact
        link_tags     = @driver.find_elements(:css, "link").select { |x| x.attribute('rel') == "canonical" }.compact
        all_links     = anchor_links + link_tags
        all_hrefs     = all_links.collect { |l| l.attribute('href')}.compact

        all_hrefs.each do |link|
          assert_equal(true, link.include?(@url))
        end
        
        if infite_content
          infite_content = infite_content.select {|x| x.displayed?}
        end
        we_reccommend     = find "div.OUTBRAIN"

        scroll_to_bottom_of_page
        sleep 1
        new_content_count = @driver.find_elements(:css, ".js-fake-infinite-content")
        if new_content_count
          new_content_count = new_content_count.select {|x| x.displayed?}
        end

        assert_equal(false, header_text.nil?, "header text was nil")
        assert_equal(true, header_text.length == headers.length, "A h2 tag was blank")
        assert_equal(true, article_links.length > 1, "Missing article links on the page")
        assert_equal(false, quote_text.nil?, "missing daily quote text")
        assert_equal(true, quote_text.length > 1, "Daily quote text was blank")
        assert_equal(7, infite_content.length, "Expected 7 infite_content but there was #{infite_content.length}" )
        assert_equal(infite_content.length, new_content_count.length)
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
        assert_equal("Sugary Drinks Tied to Nearly 200,000 Deaths a Year", @driver.title)
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
        ads               = DailyDose::DailyDosePage::LazyLoadedAds.new(:driver => @driver,
                                                                        :proxy => @proxy, 
                                                                        :url => @url,
                                                                        :ad_site => ad_site,
                                                                        :ad_categories => ad_categories,
                                                                        :exclusion_cat => exclusion_cat,
                                                                        :sponsor_kw  => sponsor_kw,
                                                                        :thcn_content_type => thcn_content_type,
                                                                        :thcn_super_cat => thcn_super_cat,
                                                                        :thcn_category => thcn_category,
                                                                        :ugc => "n",
                                                                        :trigger_point => "div.ContentListInset.js-content-inset") 
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
    cleanup_driver_and_proxy
  end 
end