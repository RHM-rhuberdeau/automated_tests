require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'

class HeartDiseaseQuestionPageTest < MiniTest::Test
  context "a Question with an expert answer" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][132860])
      @page = ::RedesignQuestionPage.new(@driver, @proxy, @question_fixture)
      visit "#{HC_BASE_URL}/heart-disease/c/question/67255/40783"
    end

    context "when functioning properly" do 
      should "have an expert answer section" do 
        expert_section = @driver.find_element(:css, ".CommentList--qa.QA-experts-container li")
        assert_equal(true, !expert_section.nil?, "Expert section did not appear on the page")
      end

      should "not expose the community answers until after view more answers is clicked" do 
        exposed_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").select {|x| x.displayed? }
        assert_equal(0, exposed_answers.length, "Only #{exposed_answers.length} answers were exposed")
      end

      should "display the full content of the experts answer" do 
        expert_answer = @driver.find_elements(:css, ".CommentList--qa.QA-experts-container li .CommentBox-secondary-content").select { |x| x.displayed?}.first
        expected_answer = "DaddysGirl,Thanksforyourquestion.Ihavehad3or4patientsthroughtheyearswhodevelopedasternalwoundinfection,andrequiredtheremovalofthesternum.Theyallhadafollow-upprocedureinwhichaflapwasplacedoverthesternum,containingabdominalwallmuscle,andsometimesunderlyingomentum.Thisservestoprotectthechestcavityfromminorcontactwithpeopleandobjects,thatmostpeoplewouldencounterindailyliving.Youmaynoticethatwhenyourfatherbreathesin,hischest/ribswillballoonoutabit,whiletheflapretractsinabit.Theoppositeoccurswhenhebreathesout.Whenliftingheavyobjects,peopleusuallytakeabreath,thenholditandexertheavypressurebycontractingtheirabdominalmuscles.Thisshouldbeavoidedbyyourfatherasthiswouldputextrapressureontheflap.Thewallsofthecavity(ribs)willsmoothoutwithtimeandshouldnotbeanissueforanothertear.Inaddition,themusclesoftheflapwillhelppreventthisalso.Youwillneedtodiscussallofyourquestionswiththesurgeon,especiallyhisfuturerestrictionsandprecautions.Wearingavestfordailyactivitiesshouldnotbenecessary.Youshouldalsoknowthatallofmypatientslivedforseveralyears,withnofurtherproblemsrelatedtotheremovaloftheirsternums.Bestwishes.MartinCane,M.D."
        assert_equal(expected_answer, expert_answer.text.gsub(" ", '').gsub("\n", ''), "Answer was #{expert_answer} not #{expected_answer}")
      end

      should "display the expert's avatar which links to the expert's profile" do 
        avatar_link  = @driver.find_element(:css, ".CommentList--qa.QA-experts-container .AuthorInfo--qa a.AuthorInfo-avatar--qa")
        avatar_image = @driver.find_element(:css, "img.Page-info-visual-image")

        avatar_link.click
        sleep 1
        assert_equal("#{HC_BASE_URL}/profiles/c/89278", @driver.current_url, "Avatar linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/89278")
      end

      should "display the expert's name which links to the expert's profile" do 
        expert_name  = @driver.find_element(:css, ".AuthorInfo--qa .AuthorInfo-name--answer a")

        assert_equal(true, "Martin Cane, M.D." == expert_name.text, "Expert name did not appear on the page")
        expert_name.click
        sleep 1
        assert_equal("#{HC_BASE_URL}/profiles/c/89278", @driver.current_url, "Avatar linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/89278")
      end

      should "display the date the expert answer was published" do 
        date = @driver.find_element(:css, "span.AuthorInfo-created").text
        assert_equal("September 14, 2008", date, "Date was #{date} not September 14, 2008")
      end

      should "not display the community answers until View More Answers is clicked" do 
        exposed_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").select {|x| x.displayed? }
        assert_equal(0, exposed_answers.length, "#{exposed_answers.length} answers were exposed")

        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }

        exposed_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").select {|x| x.displayed? }
        assert_equal(3, exposed_answers.length, "3 answers were not exposed. #{exposed_answers.length} answers were exposed")
      end

      should "not be pharma_safe after the user clicks view more answers" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click

        assert_equal(false, @page.pharma_safe?)
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

      should "have a Ask a Question button that links to the heart disease ask a question page" do 
        button = @driver.find_element(:css, ".Button--Ask")
        button.click
        wait_for { @driver.find_element(css: '.titlebar').displayed? }
        assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/profiles/c/question/home?ic=ask", "Ask a Question linked to #{@driver.current_url} not /profiles/c/question/home?ic=ask")
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
        sub_category_links = @driver.find_element(:link, "High Blood Pressure")
        sub_category_links = @driver.find_element(:link, "Cholesterol")
        sub_category_links = @driver.find_element(:link, "Diabetes")
        sub_category_links = @driver.find_element(:link, "Menopause")
        sub_category_links = @driver.find_element(:link, "Obesity")
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