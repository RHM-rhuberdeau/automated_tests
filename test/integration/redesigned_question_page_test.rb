require_relative '../minitest_helper' 
require_relative '../redesign_question_page'

class RedesignedQuestionPageTest< MiniTest::Test
  context "a redesigned Shareposts Question page" do 
  	setup do
  	  firefox_with_proxy
      @proxy.new_har
  	end

    context "without an expert answer" do
      setup do
        visit "#{HC_BASE_URL}/heart-disease/c/question/295822/173882"
        @page = ::RedesignQuestionPage.new(@driver, @proxy)
      end
      should "load the correct analytics file" do
        assert_equal(true, @page.analytics_file)
      end

      should "not be pharma safe" do
        assert_equal(false, @page.pharma_safe?)
      end

      should "have a ugc value of y" do
        assert_equal(true, (@page.ugc == "[\"y\"]"), "#{@page.ugc.inspect}")
      end
    end#without an expert answer

    context "a Question with an expert answer" do
      setup do
        visit "#{HC_BASE_URL}/heart-disease/c/question/230633/173694"
        @page = ::RedesignQuestionPage.new(@driver, @proxy)
      end

      should "be pharma safe" do
        assert_equal(true, @page.pharma_safe?)
      end

      should "have a ugc value of n" do
        assert_equal(true, (@page.ugc == "[\"n\"]"), "#{@page.ugc.inspect}")
      end
    end
  end#a redesigned Shareposts Entry page

  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end