require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/subcategory_page'
  
class HCSearchTest < MiniTest::Test
  context "a search query" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentral::SubcategoryPage.new(:driver => @driver,:proxy => @proxy)
    end

    should "produce results" do
      visit "#{HC_BASE_URL}"

      element = @driver.find_element(:css, "#q")
      element.send_keys "diabetes"
      button = @driver.find_element(:css, ".icon-search")
      button.click
      wait_for_page_to_load
      assert_equal("Search Results", (@driver.find_element(:css, 'div.page div.body.portal div.content.results h1')).text)
      assert_equal(true, (@driver.find_elements(:css, "div.page div.body.portal div.content.results ul.results li h3 a").length) >= 1)
    end

    ###################################################################
    #################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Healthcentral Search Results"), "Page title was: #{@page.driver.title}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe             = evaluate_script("EXCLUSION_CAT")
        pharma_safe             = pharma_safe == ""
        ad_site                 = evaluate_script("AD_SITE")
        expected_ad_site        = "cm.own.healthcentral"
        expected_ad_categories  = ['generalhealth','','']
        actual_ad_categories    = evaluate_script("AD_CATEGORIES")
        ads                     = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => "#{HC_BASE_URL}/chronic-pain/",
                                                                     :ad_site => ad_site,
                                                                     :expected_ad_site => expected_ad_site,
                                                                     :ad_categories => actual_ad_categories,
                                                                     :expected_ad_categories => expected_ad_categories,
                                                                     :pharma_safe => pharma_safe,
                                                                     :expected_pharma_safe => true,
                                                                     :ugc => "[\"n\"]") 
        ads.validate

        assert_equal(true, (ads.errors.empty?), "#{ads.errors.messages}")
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
  end#a search query

  def teardown  
    @driver.quit 
    @proxy.close
  end 
end