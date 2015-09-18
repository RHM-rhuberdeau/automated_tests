require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_question_page'

class ChronicPainQuestionPageTest < MiniTest::Test
  context "a question with lots of community answers" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][125351])
      @page = ::RedesignQuestion::RedesignQuestionPage.new(:driver => @driver,:proxy => @proxy,:fixture => @question_fixture)
      @url  = "#{HC_BASE_URL}/chronic-pain/c/question/515205/125351" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
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
     context "SEO safe" do 
       should "have the correct title" do 
         seo = @page.seo(:driver => @driver) 
         seo.validate
         assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
       end
     end

     ##################################################################
     ################### ASSETS #######################################
     context "assets" do 
       should "have valid assets" do 
         assets = @page.assets(:base_url => @url)
         assets.validate
         assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
       end
     end

     #########################################################################
     ################### ADS, ANALYTICS, OMNITURE ############################
     context "ads, analytics, omniture" do
       should "not have any errors" do 
         pharma_safe   = true
         has_file      = @page.analytics_file
         ad_site       = "cm.ver.chronicpain"
         ad_categories = ["chronicpain","basics",""]
         ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => @url,
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "",
                                                            :sponsor_kw => '',
                                                            :thcn_content_type => "Questions",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Bones, Joints, & Muscles",
                                                            :ugc => "[\"n\"]") 
         ads.validate

         omniture = @page.omniture(:url => @url)
         omniture.validate
         assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
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