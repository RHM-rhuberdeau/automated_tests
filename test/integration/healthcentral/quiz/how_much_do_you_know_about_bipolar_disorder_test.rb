require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/quiz_page'

class QuizTest < MiniTest::Test
  context "how-much-do-you-know-about-bipolar-disorder" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/quizes.yml')
      quiz_fixture = YAML::load_documents(io)
      @quiz_fixture = OpenStruct.new(quiz_fixture[0]['bipolar'])
      @page = ::HealthCentral::QuizPage.new(:driver => @driver,:proxy => @proxy,:fixture => @quiz_fixture)
      @url  = "#{HC_BASE_URL}/bipolar/cf/quizzes/how-much-do-you-know-about-bipolar-disorder" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
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
        assets = @page.assets(:base_url => @url)
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "How Much Do You Know About Biploar Disorder? - Bipolar Disorder"), "Page title was: #{@page.driver.title}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe    = true
        ad_site        = "cm.own.tcc"
        ad_categories  = ["seroquel", "", ""]
        ads            = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => @url,
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "",
                                                            :sponsor_kw => 'SPONSOR_KW',
                                                            :thcn_content_type => "Quiz",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Mental Health",
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