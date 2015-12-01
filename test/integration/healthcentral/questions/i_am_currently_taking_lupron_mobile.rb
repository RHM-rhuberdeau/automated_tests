require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_mobile_question_page'

class LupronMobileQuestionPageTest < MiniTest::Test
  context "a mobile question without an expert answer" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/questions.yml')
      question_fixture = YAML::load_documents(io)
      @question_fixture = OpenStruct.new(question_fixture[0]['diet_exercise_mobile'])
      head_navigation   = HealthCentralHeader::MobileRedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Diet & Exercise",
                                   :related_links => ['Asthma', 'Cholesterol', 'High Blood Pressure', 'Obesity'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page = ::RedesignQuestion::RedesignMobileQuestionPage.new(:driver => @driver,:proxy => @proxy,:fixture => @question_fixture, :head_navigation => head_navigation, :footer => footer)
      @url  =  "#{HC_BASE_URL}/diet-exercise/c/question/748553/132860/" + $_cache_buster
      visit @url
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
        ad_site       = "cm.ver.diet"
        ad_categories = ["exercisefitness","smokingcessation",""]
        ads           = RedesignQuestion::RedesignMobileQuestionPage::LazyLoadedAds.new(:driver => @driver,
                                                           :proxy => @proxy, 
                                                           :url => @url,
                                                           :ad_site => ad_site,
                                                           :ad_categories => ad_categories,
                                                           :exclusion_cat => "community",
                                                           :sponsor_kw => '',
                                                           :thcn_content_type => "Questions",
                                                           :thcn_super_cat => "Healthy Living",
                                                           :thcn_category => "Diet and Fitness",
                                                           :ugc => "y",
                                                           :trigger_point => "li.Ad--container") 
        ads.validate
        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
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