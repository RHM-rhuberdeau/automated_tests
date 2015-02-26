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
      @page = ::RedesignQuestionPage.new(@driver, @proxy, @question_fixture)
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

      should "truncate the community answers to 7 lines" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }
        first_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
        expected_answer = "YourquestionhascometotheSkinCaresiteonHealthCentralandIdon'tthinkanyonecouldansweryouaboutyoursymptomsandwhatmightbehappening.Theycan'tdiagnoseyouovertheinternet,yet.Ifyoufeelyouneedto,youshouldcallyourdoctor,call911forimmediateassistance,ororgotoyourlocalemergencyroom...READMORE"
        assert_equal(expected_answer, first_answer, "First answer was not truncated: #{first_answer}")
      end

      should "display the full community answer after the user clicks Read More" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }
        truncated_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
        read_more = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content .js-read-more").select { |x| x.displayed? }.first
        read_more.click
        sleep 0.5
        full_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
        expected_answer = "YourquestionhascometotheSkinCaresiteonHealthCentralandIdon'tthinkanyonecouldansweryouaboutyoursymptomsandwhatmightbehappening.Theycan'tdiagnoseyouovertheinternet,yet.Ifyoufeelyouneedto,youshouldcallyourdoctor,call911forimmediateassistance,ororgotoyourlocalemergencyroom.Goodluck."
        assert_equal(expected_answer, full_answer, "Full answer was not displayed after clicking Read More: #{full_answer}")
        assert_equal(false, truncated_answer == full_answer)
      end

      should "display each member's avatar in each community answer" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(:css, ".QA-community .CommentBox-secondary-content").displayed? }
        community_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content")

        community_avatars = @driver.find_elements(:css, ".CommentList--community .CommentList-item--qa .CommentBox .CommentBox-primary-content .AuthorInfo--qa img.Page-info-visual-image")
        assert_equal(true, community_answers.length == community_avatars.length, "One or more answers is missing an avatar. Answers: #{community_answers.length} Avatars: #{community_avatars.length}")

        community_avatars.select { |x| x.displayed? }.first.click
        sleep 1
        assert_equal("#{HC_BASE_URL}/profiles/c/222743", @driver.current_url, "Avatar linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/222743")
      end

      should "display each member's name which links to the member's profile" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(:css, ".QA-community .CommentBox-secondary-content").displayed? }

        community_answers = @driver.find_elements(:css, "ul.CommentList--community li.CommentList-item--qa").select {|x| x.displayed? }
        community_names   = @driver.find_elements(:css, ".CommentList--community .CommentList-item--qa .CommentBox .CommentBox-primary-content .AuthorInfo--qa .AuthorInfo-name--answer")
        profile_links     = @driver.find_elements(:css, ".CommentList--community .CommentList-item--qa .CommentBox .CommentBox-primary-content .AuthorInfo--qa .AuthorInfo-name--answer a")
        community_names   = community_names.select { |x| x.text.gsub(" ", '').length > 0 }

        assert_equal(true, community_names.length > 0, "No names appeared on the page")
        assert_equal(true, community_answers.length == community_names.length, "Some answers were missing names: Answers #{community_answers.length} Names #{community_names.length}")
        first_user_name = profile_links.first
        first_user_name.click
        sleep 1
        assert_equal("#{HC_BASE_URL}/profiles/c/222743", @driver.current_url, "Avatar linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/222743")
      end

      should "display the date that each community answer was created" do 
        "AuthorInfo-created"
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(:css, ".QA-community .CommentBox-secondary-content").displayed? }

        community_answers = @driver.find_elements(:css, "ul.CommentList--community li.CommentList-item--qa").select {|x| x.displayed? }
        community_dates   = @driver.find_elements(:css, ".CommentList--community .CommentList-item--qa .CommentBox .CommentBox-primary-content .AuthorInfo--qa .AuthorInfo-created").select {|x| x.displayed? }
        community_dates  = community_dates.select{|x| x.text.gsub(" ", '').length > 0}

        assert_equal(true, community_dates.length > 0, "No names appeared on the page")
        assert_equal(true, community_dates[0].text == "February 27, 2011", "First date did not appear on the page: #{community_dates[0].text}")
        assert_equal(true, community_dates[1].text == "July 13, 2011",     "Second date did not appear on the page")
        assert_equal(true, community_dates[2].text == "January 01, 2012",  "Third date did not appear on the page")
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

     ##################################################################
     ################### GLOBAL SITE TESTS ############################
     context "Global site requirements" do 
       should "display the healthcentral logo" do 
         assert_equal(true, @page.logo_present?)
       end

       should "have a logo that links to the homepage" do 
         link = @driver.find_element(:css, "a.LogoHC")
         link.click
         sleep 1
         assert_equal(true, (@driver.current_url == "#{HC_BASE_URL}/"), "The logo linked to #{@driver.current_url} not #{HC_BASE_URL}/")
       end

       should "have a health a-z nav that opens after clicking it" do 
         nav = @driver.find_elements(:css, ".HC-nav")
         if nav
           nav = nav.select { |x| x.displayed? }
         end
         assert_equal(true, nav.empty?, "A-Z was on the page before clicking it #{nav}")
         button = @driver.find_element(:css, ".Button--AZ")
         button.click
         az_nav = @driver.find_element(:css, ".HC-nav")
         assert_equal(false, az_nav.nil?, "A-Z nav did not appear on the page afer clicking the Health A-Z button #{az_nav}")
       end

       should "display Body & Mind, Family Health and Healthy Living in the Health A-Z section" do 
         button = @driver.find_element(:css, ".Button--AZ")
         button.click
         wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
         titles = @driver.find_elements(:css, ".js-Nav--Primary-accordion-title").select {|x| x.displayed? }.select {|x| x.text == "BODY & MIND" || x.text == "FAMILY HEALTH" || x.text == "HEALTHY LIVING"}
         assert_equal(3, titles.length, "Not all super categories were on the page. Present were: #{titles}")
       end

       should "not have links to the super categories in the Health A-Z menu" do 
         button = @driver.find_element(:css, ".Button--AZ")
         button.click
         wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
         links = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary a").select { |x| x.text.downcase == "body & mind" || x.text.downcase == "family health" || x.text.downcase == "healthy living"}
         assert_equal(true, links.empty?, "Links to the super categories were present")
       end 

       should "have a subcategory link in the Health A-Z menu" do 
         button = @driver.find_element(:css, ".Button--AZ")
         button.click
         wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
         link = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary a").select { |x| x.text == "Digestive Health"}
         assert_equal(false, link.nil?, "Digestive Health was missing from the subcategory links")
         link.first.click
         wait_for { @driver.find_element(:css, ".Phases-navigation").displayed? }
         assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/ibd/",)
       end

       should "have a follow us Facebook icon that links to the HealthCentral facebook page" do 
         fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-facebook")
         fb_icon.click
         sleep 1
         second_window = @driver.window_handles.last
         @driver.switch_to.window second_window
         assert_equal(true, @driver.current_url == "https://www.facebook.com/HealthCentral?v=app_369284823108595", "Facebook icon linked to #{@driver.current_url} not https://www.facebook.com/HealthCentral?v=app_369284823108595")
       end

       should "have a follow us Twitter icon that links to the HealthCentral twitter page" do 
         fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-twitter")
         fb_icon.click
         sleep 1
         second_window = @driver.window_handles.last
         @driver.switch_to.window second_window
         assert_equal(true, @driver.current_url == "https://twitter.com/healthcentral", "Twitter icon linked to #{@driver.current_url} not https://twitter.com/healthcentral")
       end

       should "have a follow us Pinterest icon that links to the HealthCentral pinterest page" do 
         fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-pinterest")
         fb_icon.click
         sleep 1
         second_window = @driver.window_handles.last
         @driver.switch_to.window second_window
         assert_equal(true, @driver.current_url == "https://www.pinterest.com/HealthCentral/", "Pinterest icon linked to #{@driver.current_url} not https://www.pinterest.com/HealthCentral/")
       end

       should "have a mail icon that links to the HealthCentral newsletter subscribe page" do 
         fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-mail")
         fb_icon.click
         sleep 1
         assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/profiles/c/newsletters/subscribe", "Mail icon linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
       end

       should "have a subcategory navigation" do 
         subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
         title_link = @driver.find_element(:css, ".Page-category-titleLink")
         sub_category_links = @driver.find_elements(:css, "ul.Page-category-related-list li a")
         links = sub_category_links.select {|x| x.text == "Multiple Sclerosis" || x.text == "Rheumatoid Arthritis"}
         assert_equal(2, links.length)
       end

       should "have options to share on multiple social networks" do 
         share1 = @driver.find_element(:css, "span.icon-facebook.icon-light.js-social--share")
         share1 = @driver.find_element(:css, "span.icon-twitter.icon-light.js-social--share")
         share1 = @driver.find_element(:css, "span.icon-stumbleupon.icon-light.js-social--share")
         share1 = @driver.find_element(:css, "span.icon-mail.icon-light.js-social--share")
       end

       should "have a footer with necessary links" do 
         footer_links = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "About Us" || x.text == "Contact Us" || x.text == "Privacy Policy" || x.text == "Terms of Use" || x.text == "Security Policy" || x.text == "Advertising Policy" || x.text == "Advertise With Us" }
         assert_equal(true, footer_links.length == 7, "Links missing from footer: #{footer_links}")

         other_sites = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "The Body" || x.text == "The Body Pro" || x.text == "Berkeley Wellness" || x.text == "Health Communities" || x.text == "Health After 50" || x.text == "Intelecare" || x.text == "Mood 24/7"}
         assert_equal(true, other_sites.length == 7, "Missing links to other sites in the footer: #{other_sites.length}")
       end
     end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end