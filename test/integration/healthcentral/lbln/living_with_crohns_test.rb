require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'

class LBLN < MiniTest::Test
  context "living with crohns" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::RedesignQuestionPage.new(@driver, @proxy)
      visit "#{HC_DRUPAL_URL}/ibd/d/immersive/living-crohns-disease-update/?ic=herothirds"
    end

    should "have an adsite value of cm.ver.lblnibd" do 
      ad_site = evaluate_script("AD_SITE")
      assert_equal(true, (ad_site == "cm.ver.lblnibd"), "ad_site was #{ad_site} not cm.ver.lblnibd")
    end

    should "have ad_categories value of ['lblnra', 'livingwith', '']" do 
      expected_ad_categories = ["immersive", "livingwith", ""]
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

    should "have the correct title" do 
      assert_equal(true, @page.has_correct_title?, "Page title was: #{@page.driver.title}")
    end

    should "not have unloaded assets" do 
      assert_equal(false, @page.has_unloaded_assets?, "#{@page.unloaded_assets}")
    end

    should "load assets from the correct environment" do 
      assert_equal(true, @page.wrong_assets.empty?, "wrong assets: #{@page.wrong_assets}")
      assert_equal(false, @page.right_assets.empty?, "right assets empty: #{@page.right_assets}")
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end