require_relative '../../../minitest_helper' 
require_relative '../../../pages/the_body/lbln_page'

class LivingWithHiv < MiniTest::Test
  context "A TheBody desktop lbln page" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io            = File.open('test/fixtures/the_body/lbln.yml')
      body_fixture  = YAML::load_documents(io)
      @body_fixture = OpenStruct.new(body_fixture[0]['living_with_hiv'])
      @page         = TheBodyLBLN::TheBodyLBLNPage.new(:driver => @driver, :proxy => @proxy, :fixture => @body_fixture)
      @url          = "#{BODY_URL}/LBLN/living-with-hiv/index.html"
      visit @url
    end


    # ##################################################################
    # ################ FUNCTIONALITY ###################################
    # context "when functioning properly" do 
    #   should "not have any errors" do 
    #     functionality = @page.functionality
    #     functionality.validate
    #     assert_equal(true, functionality.errors.empty?, "#{functionality.errors.messages}")
    #   end
    # end

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
        ads       = TheBodyLBLN::TheBodyLBLNPage::DesktopAds.new(:driver => @driver,
                                                             :proxy => @proxy, 
                                                             :ad_site => 'cm.own.thebody',
                                                             :ad_categories => ['lbln', 'index'],
                                                             :exclusion_cat => "",
                                                             :sponsor_kw  => "lblnhiv",
                                                             :thcn_content_type => "super collection",
                                                             :thcn_super_cat => "Resource Center",
                                                             :thcn_category => "HIV",
                                                             :ugc => "[\"n\"]",
                                                             :url => @url) 
        ads.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

    # ##################################################################
    # ################### GLOBAL SITE TESTS ############################
    # context "Global Site tests" do 
    #   should "have passing global test cases" do 
    #     button = find "#HC-menu"
    #     button.click if button
        
    #     global_test_cases = @page.global_test_cases
    #     global_test_cases.validate
    #     assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
    #   end
    # end
  end#A TheBody desktop page

  def teardown  
    @driver.quit  
    @proxy.close
  end
end