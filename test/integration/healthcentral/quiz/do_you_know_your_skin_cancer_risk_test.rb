require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'

class QuizTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/quizes.yml')
      quiz_fixture = YAML::load_documents(io)
      @quiz_fixture = OpenStruct.new(quiz_fixture[0]['cancerrisk'])
      @page = ::HealthCentralPage.new(@driver, @proxy, @quiz_fixture)
      visit "#{HC_BASE_URL}/skin-cancer/d/quizzes/do-you-know-your-skin-cancer-risk"
    end

    context "when functioning properly" do
      should "update the ads between each slides" do 
        @page.go_through_quiz
        assert_equal(true, @page.has_unique_ads?)
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

    # ##################################################################
    # ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Do You Know Your Skin Cancer Risk? - "), "Page title was: #{@page.driver.title}")
      end
    end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics and omniture" do 
      should "have an adsite value of cm.ver.chronicpain" do 
        expected_ad_site = "cm.ver.skin-cancer"
        ad_site          = evaluate_script("AD_SITE")
        assert_equal(true, (ad_site == expected_ad_site), "ad_site was #{ad_site} not #{expected_ad_site}")
      end

      should "have ad_categories value of ['home', '', '']" do 
        expected_ad_categories = ["quiz", "doyouknowy", ""]
        actual_ad_categories   = evaluate_script("AD_CATEGORIES")
        assert_equal(true, (actual_ad_categories == expected_ad_categories), "ad_categories was #{actual_ad_categories} not #{expected_ad_categories}")
      end

      should "have unique ads" do 
        ads1 = @page.ads_on_page
        @driver.navigate.refresh
        sleep 1
        ads2 = @page.ads_on_page

        ord_values_1 = ads1.collect(&:ord).uniq
        ord_values_2 = ads2.collect(&:ord).uniq

        assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
        assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
        assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end

      should "have valid omniture values" do 
        omniture = @page.omniture
        omniture.validate
        assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end