require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/quiz_page'

class QuizTest < MiniTest::Test
  context "do-you-know-how-manage-your-pain" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/quizes.yml')
      quiz_fixture = YAML::load_documents(io)
      @quiz_fixture = OpenStruct.new(quiz_fixture[0]['managepain'])
      @page = ::HealthCentral::QuizPage.new(:driver => @driver,:proxy => @proxy,:fixture => @quiz_fixture)
      visit "#{HC_BASE_URL}/rheumatoid-arthritis/d/quizzes/do-you-know-how-manage-your-pain"
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality
        functionality.validate
        assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
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

    ###################################################################
    #################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Do You Know How to Manage Your Pain? - Rheumatoid Arthritis"), "Page title was: #{@driver.title}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe    = true
        ad_site        = "cm.ver.lblnra"
        ad_categories  = ["quiz", "doyouknowh", ""]
        ads            = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => "#{HC_BASE_URL}/rheumatoid-arthritis/d/quizzes/do-you-know-how-manage-your-pain",
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "",
                                                            :sponsor_kw => 'SPONSOR_KW',
                                                            :thcn_content_type => "Quiz",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Bones, Joints, & Muscles",
                                                            :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end