require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_question_page'

class HeartDiseaseQuestionPageTest < MiniTest::Test
  context "a Question with an expert answer" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0][40783])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Heart Disease",
                                   :related => ['High Blood Pressure', 'Cholesterol', 'Diabetes', 'Menopause', 'Obesity'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = RedesignQuestion::RedesignQuestionPage.new(:driver =>@driver,:proxy => @proxy,:fixture => @question_fixture, :head_navigation => head_navigation, :footer => footer)
      @url              = "#{HC_BASE_URL}/heart-disease/c/question/67255/40783" + $_cache_buster
      visit @url
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

        wait_for { @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first.displayed? }
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click
        wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }

        exposed_answers = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").select {|x| x.displayed? }
        assert_equal(3, exposed_answers.length, "3 answers were not exposed. #{exposed_answers.length} answers were exposed")
      end

      should "not be pharma_safe after the user clicks view more answers" do 
        wait_for { @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first.displayed? }
        view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
        view_more_answers.click

        assert_equal(false, @page.pharma_safe?)
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
        ad_site       = "cm.ver.heartdisease"
        ad_categories = ["heartdisease","smokingcessation",""]
        ads           = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "Questions",
                                                           :thcn_super_cat => "Body & Mind",
                                                           :thcn_category => "Heart Health",
                                                           :ugc => "n") 
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
      end
    end
  end

  def teardown  
    cleanup_driver_and_proxy
  end 
end