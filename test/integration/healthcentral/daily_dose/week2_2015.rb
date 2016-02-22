require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/dailydose_page'

class DailyDoseSecondWeek < MiniTest::Test
  include Capybara::DSL

  context "daily dose second week, 2015" do 

    setup do 
      capybara_with_phantomjs
      @driver           = Capybara.current_session
      io                = File.open('test/fixtures/healthcentral/daily_dose.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['week2'])
      head_navigation   = HealthCentralHeader::DailyDoseDesktop.new(:driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = DailyDose::DailyDosePage.new(:driver => @driver,:proxy => @proxy,:fixture => topic_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      @url              = "#{HC_BASE_URL}/dailydose/2015/2" + $_cache_buster
      preload_page @url
      visit @url
       wait_for {find("h2.title").visible?}
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        header            = find "h2.title"
        header_text       = header.text if header 
        article_links     = all(:css, "ul.ContentList--article li.ContentList-item a") || []
        pagination_links  = all(:css, "div.ArticlePaginationRange a") || []
        we_reccommend     = find "div.OUTBRAIN"
        anchor_links      = all('a[rel="canonical"]', :visible => false)
        link_tags         = all('link[rel="canonical"]', :visible => false)
        all_links         = anchor_links.to_a + link_tags.to_a
        all_hrefs         = all_links.collect { |l| l[:href]}.compact

        all_hrefs.each do |link|
          assert_equal(true, @url.include?(link))
        end

        assert_equal(false, header_text.nil?, "header title nil")
        assert_equal(true, header_text.length > 1, "header text blank")
        assert_equal(true, article_links.length > 1, "missing article links")
        assert_equal(true, pagination_links.length == 2, "missing pagination links")
        assert_equal(false, we_reccommend.nil?, "we recommend is blank")
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
    context "SEO" do 
      should "have the correct title" do 
        assert_equal("Health News: Jan 14th-Jan 8th", @driver.title)
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