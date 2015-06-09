require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class ItMightBeSomethingEntryPageTest < MiniTest::Test
  context "a community member entry" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture = YAML::load_documents(io)
      @entry_fixture = OpenStruct.new(entry_fixture[0][173745])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Multiple Sclerosis",
                                   :related => ['Chronic Pain', 'Depression', 'Rhematoid Arthritis'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::RedesignEntry::RedesignEntryPage.new(:driver => @driver,:proxy => @proxy,:fixture => @entry_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/multiple-sclerosis/c/936913/173745/might-something"
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:author_name => "robinoakapple1", :author_role => "Community Member", :nofollow_author_links => true, :profile_link => "#{HC_BASE_URL}/profiles/c/936913")
        functionality.validate
        assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
      end
    end

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, @page.has_correct_title?)
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe   = false
        has_file      = @page.analytics_file
        ad_site       = "cm.ver.ms"
        ad_categories = ["multiplesclerosis","whentoseeadoctor",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => "#{HC_BASE_URL}/multiple-sclerosis/c/936913/173745/might-something",
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "community",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "SharePosts",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Brain and Nervous System",
                                                           :ugc => "[\"y\"]") 
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

        subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
        title_link = @driver.find_element(:css, ".Page-category-titleLink")
        sub_category_links = @driver.find_element(:link, "Chronic Pain")
        sub_category_links = @driver.find_element(:link, "Depression")
        sub_category_links = @driver.find_element(:link, "Rheumatoid Arthritis")

        button = @driver.find_element(:css, ".Button--Ask")
        button.click
        wait_for { @driver.find_element(css: '.titlebar').displayed? }
        assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/multiple-sclerosis/c/question", "Ask a Question linked to #{@driver.current_url} not /multiple-sclerosis/c/question")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end