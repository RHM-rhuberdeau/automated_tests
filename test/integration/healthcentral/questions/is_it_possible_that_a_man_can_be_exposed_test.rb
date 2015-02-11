require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'

class QuestionPageTest < MiniTest::Test
  context "a question without an expert answer" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::RedesignQuestionPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/erectile-dysfunction/c/question/277738/167616"
    end

    should "load the correct analytics file" do
      assert_equal(@page.analytics_file, true)
    end

    should "not be pharma safe" do
      assert_equal(false, @page.pharma_safe?)
    end

    should "have the correct title" do 
      assert_equal(true, @page.has_correct_title?)
    end

    should "not have unloaded assets" do 
      assert_equal(false, @page.has_unloaded_assets?, "#{@page.unloaded_assets}")
    end

    should "load assets from the correct environment" do 
      assert_equal(true, @page.wrong_assets.empty?, "wrong assets: #{@page.wrong_assets}")
      assert_equal(false, @page.right_assets.empty?, "right assets empty: #{@page.right_assets}")
    end

    should "have a ugc value of y" do
      assert_equal(true, (@page.ugc == "[\"y\"]"), "#{@page.ugc.inspect}")
    end

    should "have unique ads" do 
      ads1 = @page.ads_on_page
      visit "#{@driver.current_url}"
      sleep 0.5
      ads2 = @page.ads_on_page

      ord_values_1 = ads1.collect(&:ord).uniq
      ord_values_2 = ads2.collect(&:ord).uniq

      assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
      assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
      assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end