require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/quiz_page'

class QuizTest < MiniTest::Test
  context "do-you-know-your-skin-cancer-risk" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/quizes.yml')
      quiz_fixture = YAML::load_documents(io)
      @quiz_fixture = OpenStruct.new(quiz_fixture[0]['cancerrisk'])
      @page = ::HealthCentral::QuizPage.new(:driver => @driver,:proxy => @proxy,:fixture => @quiz_fixture)
      @url  = "#{HC_BASE_URL}/skin-cancer/d/quizzes/do-you-know-your-skin-cancer-risk" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
    end

    ###################################################################
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
    context "SEO safe" do 
      should "have the correct title" do 
        seo = @page.seo(:driver => @driver) 
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe    = true
        ad_site        = "cm.ver.skin-cancer"
        ad_categories  = ["quiz", "doyouknowy", ""]
        ads            = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => @url,
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "",
                                                            :sponsor_kw => '',
                                                            :thcn_content_type => "Quiz",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Cancer",
                                                            :ugc => "[\"n\"]")
        ads.validate

        omniture = @page.omniture(:url => @url)
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