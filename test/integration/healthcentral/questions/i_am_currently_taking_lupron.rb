require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'

class DietExerciseQuestionPageTest < MiniTest::Test
  context "a question without an expert answer" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][132860])
      @page = ::RedesignQuestion::RedesignQuestionPage.new(@driver, @proxy, @question_fixture)
      visit "#{HC_BASE_URL}/diet-exercise/c/question/748553/132860/"
    end

    # context "when functioning properly" do 
    #   should "not have an expert answer section" do 
    #     begin
    #       expert_section = @driver.find_element(:css, ".CommentList--qa.QA-experts-container li")
    #     rescue Selenium::WebDriver::Error::NoSuchElementError
    #       expert_section = nil
    #     end
    #     assert_equal(true, expert_section.nil?, "Expert section did not appear on the page")
    #   end

    #   should "have a message that the question has not been answered by an expert" do
    #     expected_message = "This question has not been answered by one of our experts yet."
    #     no_expert_message = @driver.find_element(:css, ".QA-experts-no-answer").text
    #     assert_equal(true, no_expert_message == expected_message, "#{expected_message} did not appearon the page, #{no_expert_message} did") 
    #   end

    #   should "expose the community answers if there are no expert answers" do 
    #     exposed_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").select {|x| x.displayed? }
    #     assert_equal(3, exposed_answers.length, "3 answers were not exposed. #{exposed_answers.length} answers were exposed")
    #   end
    # end

     ##################################################################
     ################### SEO ##########################################
     # context "SEO" do 
     #   should "have the correct title" do 
     #     assert_equal(true, @page.has_correct_title?)
     #   end
     # end

     ##################################################################
     ################### ASSETS #######################################
     # context "assets" do 
     #   should "have valid assets" do 
     #     assets = @page.assets
     #     assets.validate
     #     assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
     #   end
     # end

     #########################################################################
     ################### ADS, ANALYTICS, OMNITURE ############################
     # context "ads, analytics, omniture" do 
     #   should "load the correct analytics file" do
     #     assert_equal(@page.analytics_file, true)
     #   end

     #   should "not be pharma safe" do
     #     assert_equal(false, @page.pharma_safe?)
     #   end

     #   should "have a ugc value of y" do
     #     assert_equal(true, (@page.ugc == "[\"y\"]"), "#{@page.ugc.inspect}")
     #   end

     #   should "have unique ads" do 
     #     ads1 = @page.ads_on_page
     #     @driver.navigate.refresh
     #     sleep 1
     #     ads2 = @page.ads_on_page

     #     ord_values_1 = ads1.collect(&:ord).uniq
     #     ord_values_2 = ads2.collect(&:ord).uniq

     #     assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
     #     assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
     #     assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
     #   end

     #   should "have valid omniture values" do 
     #     omniture = @page.omniture
     #     omniture.validate
     #     assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
     #   end
     # end

     ##################################################################
     ################### GLOBAL SITE TESTS ############################
     context "Global site requirements" do 
       should "have passing global test cases" do 
         global_test_cases = @page.global_test_cases
         global_test_cases.validate
         assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

         subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
         title_link = @driver.find_element(:css, ".Page-category-titleLink")
         sub_category_links = @driver.find_element(:link, "Asthma")
         sub_category_links = @driver.find_element(:link, "Cholesterol")
         sub_category_links = @driver.find_element(:link, "High Blood Pressure")
         sub_category_links = @driver.find_element(:link, "Obesity")

         button = @driver.find_elements(:css, ".Button--Ask").select { |x| x.displayed? }.compact
         assert_equal(true, !button.empty?, "Ask a Question button does not appear on the page", )
         button.first.click
         wait_for { @driver.find_element(css: '.titlebar').displayed? }
         assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/profiles/c/question/home?ic=ask", "Ask a Question linked to #{@driver.current_url} not /profiles/c/question/home?ic=ask")
       end
     end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end