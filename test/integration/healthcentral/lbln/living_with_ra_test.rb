require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_entry_page'

class LBLN < MiniTest::Test
  context "living with ra" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/lbln.yml')
      lbln_fixture = YAML::load_documents(io)
      @lbln_fixture = OpenStruct.new(lbln_fixture[0]['ra'])
      @page = RedesignEntry::RedesignEntryPage.new(@driver, @proxy, @lbln_fixture)
      visit "#{HC_BASE_URL}/rheumatoid-arthritis/d/immersive/living-ra-update/?ic=herothirds"
    end

    ##################################################################
    ################### ASSETS #######################################
    # context "assets" do 
    #   should "have valid assets" do 
    #     assets = @page.assets
    #     assets.validate
    #     assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
    #   end
    # end

    ##################################################################
    ################### SEO ##########################################
    # context "SEO" do 
    #   should "have the correct title" do 
    #     assert_equal(true, @page.has_correct_title?)
    #   end
    # end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      # should "be pharma safe" do
      #   assert_equal(true, @page.pharma_safe?)
      # end

      # should "load the correct analytics file" do
      #   assert_equal(@page.analytics_file, true)
      # end

      # should "have an adsite value of cm.ver.lblnra" do 
      #   ad_site = evaluate_script("AD_SITE")
      #   assert_equal(true, (ad_site == "cm.ver.lblnra"), "ad_site was #{ad_site} not cm.ver.lblnra")
      # end

      # should "have ad_categories value of ['lblnra', 'livingwith', '']" do 
      #   expected_ad_categories = ["immersive", "livingwith", ""]
      #   actual_ad_categories   = evaluate_script("AD_CATEGORIES")
      #   assert_equal(true, (actual_ad_categories == expected_ad_categories), "ad_categories was #{actual_ad_categories} not #{expected_ad_categories}")
      # end

      should "have unique ads" do 
        ads1 = @page.ads_on_page(3)
        visit "#{HC_BASE_URL}/rheumatoid-arthritis/d/immersive/living-ra-update/?ic=herothirds"
        sleep 1
        ads2 = @page.ads_on_page(3)

        ord_values_1 = ads1.collect(&:ord).uniq
        ord_values_2 = ads2.collect(&:ord).uniq
    
        assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
        assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
        assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end

      # should "have valid omniture values" do 
      #   omniture = @page.omniture
      #   omniture.validate
      #   assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      # end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    # context "Global Site tests" do 
    #   should "have passing global test cases" do 
    #     # global_test_cases = @page.global_test_cases
    #     # global_test_cases.validate
    #     # assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

    #     subnav = @driver.find_element(:css, ".Logo-supercollection img")
    #     sub_category_links = @driver.find_element(:link, "more on Rheumatoid Arthritis »")

    #     button = @driver.find_element(:css, ".Button--Ask")
    #     button.click
    #     wait_for { @driver.find_element(css: '.titlebar').displayed? }
    #     assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/rheumatoid-arthritis/c/question", "Ask a Question linked to #{@driver.current_url} not /rheumatoid-arthritis/c/question")
    #   end
    # end
  end

  def teardown  
    @driver.quit  
  end 
end