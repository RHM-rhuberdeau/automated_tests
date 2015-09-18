require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_question_page'

class SkinCareQuestionPageTest < MiniTest::Test
  context "a question with lots of community answers" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][132858])
      @page = ::RedesignQuestion::RedesignQuestionPage.new(:driver => @driver,:proxy => @proxy,:fixture => @question_fixture)
      @url  = "#{HC_BASE_URL}/skin-care/c/question/550423/132858" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "truncate the community answers to 7 lines" do 
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }
        first_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
        expected_answer = "YourquestionhascometotheSkinCaresiteonHealthCentralandIdon'tthinkanyonecouldansweryouaboutyoursymptomsandwhatmightbehappening.Theycan'tdiagnoseyouovertheinternet,yet...READMORE"
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
        wait_for { @driver.find_element(:css, "div#my_profile").displayed? }
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
        wait_for { @driver.find_element(:css, "div#my_profile").displayed? }
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
        assert_equal(true, community_dates[0].text == "February 26, 2011", "First date did not appear on the page: #{community_dates[0].text}")
        assert_equal(true, community_dates[1].text == "July 13, 2011",     "Second date did not appear on the page")
        assert_equal(true, community_dates[2].text == "January 01, 2012",  "Third date did not appear on the page")
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
        ad_site       = "cm.ver.skin"
        ad_categories = ["skinhealth","acne",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "Questions",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Skin Health",
                                                           :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

    # ##################################################################
    # ################### GLOBAL SITE TESTS ############################
    # context "Global site requirements" do 
    #   should "have passing global test cases" do 
    #     global_test_cases = @page.global_test_cases
    #     global_test_cases.validate
    #     assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

    #     subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
    #     title_link = @driver.find_element(:css, ".Page-category-titleLink")
    #     sub_category_links = @driver.find_element(:link, "Skin Cancer")
    #   end
    # end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end