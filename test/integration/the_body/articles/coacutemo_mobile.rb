require_relative '../../../minitest_helper' 
require_relative '../../../pages/the_body/redesign_article_page'

class CoacutemoMobile < MiniTest::Test
  context "A mobile rescource center article with 2 authors" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io            = File.open('test/fixtures/the_body/articles.yml')
      body_fixture  = YAML::load_documents(io)
      @body_fixture = OpenStruct.new(body_fixture[0]['coacutemo_mobile'])
      header        = TheBodyHeader::RedesignMobileHeader.new(:driver => @driver)
      footer        = TheBodyFooter::RedesignMobileFooter.new(:driver => @driver)
      @page         = TheBodyArticle::RedesignArticlePage.new(:driver => @driver, :proxy => @proxy, :fixture => @body_fixture,
                                                             :header => header, :footer => footer)
      @url          = "#{BODY_URL}/content/76099/coacutemo-revelar-la-noticia.html/"
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
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, @page.has_correct_title?)
      end
    end

   #########################################################################
   ################### ADS, ANALYTICS, OMNITURE ############################
   context "ads, analytics, omniture" do
     should "not have any errors" do 
       omniture  = @page.omniture
       omniture.validate
       ads               = TheBodyArticle::RedesignArticlePage::LazyLoadedAds.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :ad_site => 'cm.own.body',
                                                            :ad_categories => ['healthcentral'],
                                                            :exclusion_cat => "",
                                                            :sponsor_kw  => "latinorc",
                                                            :thcn_content_type => "BodyPage",
                                                            :thcn_super_cat => "The Body (HIV/AIDS)",
                                                            :thcn_category => "Resource Centers",
                                                            :ugc => "[\"n\"]",
                                                            :trigger_point => ".js-article-contents div.ContentListInset.js-content-inset") 
       ads.validate
       assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
     end
   end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      should "have passing global test cases" do 
        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
      end
    end
  end#A TheBody desktop page

  def teardown  
    @driver.quit  
    @proxy.close
  end
end