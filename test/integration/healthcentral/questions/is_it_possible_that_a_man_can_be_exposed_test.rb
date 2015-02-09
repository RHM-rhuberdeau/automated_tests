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
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end