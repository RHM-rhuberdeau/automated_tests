require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'
require 'yaml'
require 'ostruct'

class ChronicPainQuestionPageTest < MiniTest::Test
  context "a question with lots of community answers" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][125351])
      @page = ::RedesignQuestion::RedesignQuestionPage.new(@driver, @proxy, @question_fixture)
      visit "#{HC_BASE_URL}/chronic-pain/c/question/515205/125351"
    end

    context "when functioning properly" do 
      should "have a healthpages module" do 
        healthpage_modules = @driver.find_elements(:css, ".Editor-picks-item.Editor-picks-item-auth-pic").select {|x| x.displayed? }
        assert_equal(3, healthpage_modules.length)
      end

      should "have a clickable title in each healthpage module" do 
        titles = @driver.find_elements(:css, ".Editor-picks-item.Editor-picks-item-auth-pic .Teaser-title a").select {|x| x.displayed? }
        assert_equal(3, titles.length)
      end

      should "have a description in each healtpage module" do 
        descriptions = @driver.find_elements(:css, ".Editor-picks-item.Editor-picks-item-auth-pic .Editor-picks-content").select {|x| x.text.gsub(" ",'').length > 0}.select {|x| x.displayed? }
        assert_equal(3, descriptions.length)
      end

      should "have an expert answer section" do 
        begin
          expert_section = @driver.find_element(:css, ".CommentList--qa.QA-experts-container li")
        rescue Selenium::WebDriver::Error::NoSuchElementError
          expert_section = nil
        end
        assert_equal(true, !expert_section.nil?, "Expert section did not appear on the page")
      end

      should "have relatlive links in the header" do 
        links = (@driver.find_elements(:css, ".js-HC-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end

      should "have relative links in the right rail" do 
        wait_for { @driver.find_element(:css, ".MostPopular-container").displayed? }
        links = (@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact - @driver.find_elements(:css, "span.RightrailbuttonpromoItem-title a").collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link 
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end
    end

     ##################################################################
     ################### SEO ##########################################
     context "SEO" do 
       should "have the correct title" do 
         assert_equal(true, @page.has_correct_title?)
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

     #########################################################################
     ################### ADS, ANALYTICS, OMNITURE ############################
     context "ads, analytics, omniture" do 
       should "load the correct analytics file" do
         assert_equal(@page.analytics_file, true)
       end

       should "be pharma safe" do
         assert_equal(true, @page.pharma_safe?)
       end

       should "have a ugc value of n" do
         assert_equal(true, (@page.ugc == "[\"n\"]"), "#{@page.ugc.inspect}")
       end

       should "have unique ads" do 
         ads1 = @page.ads_on_page
         visit "#{HC_BASE_URL}/chronic-pain/c/question/515205/125351"
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

     #################################################################
     ################## GLOBAL SITE TESTS ############################
     context "Global site requirements" do 
       should "have passing global test cases" do 
         global_test_cases = @page.global_test_cases
         global_test_cases.validate
         assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

         subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
         title_link = @driver.find_element(:css, ".Page-category-titleLink")
         sub_category_links = @driver.find_elements(:css, "ul.Page-category-related-list li a")
         links = sub_category_links.select {|x| x.text == "Multiple Sclerosis" || x.text == "Rheumatoid Arthritis"}
         assert_equal(2, links.length)

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