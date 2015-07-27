require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class LBLN < MiniTest::Test
  context "living with ra" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/lbln.yml')
      lbln_fixture = YAML::load_documents(io)
      @lbln_fixture = OpenStruct.new(lbln_fixture[0]['ra'])
      @page = RedesignEntry::RedesignEntryPage.new(:driver => @driver, :proxy => @proxy, :fixture => @lbln_fixture)
      @url  = "#{HC_BASE_URL}/rheumatoid-arthritis/d/immersive/living-ra-update/?ic=herothirds"
      visit @url
    end

    #################################################################
    ################## ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets(:base_url => @url)
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    # #################################################################
    # ################## SEO ##########################################
    # context "SEO" do 
    #   should "have the correct title" do 
    #     assert_equal(true, @page.has_correct_title?)
    #   end
    # end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    # context "ads, analytics, omniture" do
    #   should "not have any errors" do 
    #     ad_site                 = "cm.ver.lblnra"
    #     ad_categories           = ["immersive", "livingwith", ""]
    #     ads                     = HealthCentralAds::AdsTestCases.new(:driver => @driver,
    #                                                                  :proxy => @proxy, 
    #                                                                  :url => "#{HC_DRUPAL_URL}/rheumatoid-arthritis/d/immersive/living-ra-update/?ic=herothirds",
    #                                                                  :ad_site => ad_site,
    #                                                                  :ad_categories => ad_categories,
    #                                                                  :exclusion_cat => "",
    #                                                                  :sponsor_kw => 'SPONSOR_KW',
    #                                                                  :thcn_content_type => "Immersive",
    #                                                                  :thcn_super_cat => "Body & Mind",
    #                                                                  :thcn_category => "Bones, Joints, & Muscles",
    #                                                                  :ugc => "[\"n\"]") 
    #     ads.validate

    #     omniture = @page.omniture
    #     omniture.validate
    #     assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
    #   end
    # end

    # #################################################################
    # ################## GLOBAL SITE TESTS ############################
    # context "Global Site tests" do 
    #   should "have passing global test cases" do 
    #     subnav = @driver.find_element(:css, ".Logo-supercollection img")
    #     sub_category_links = @driver.find_element(:link, "more on Rheumatoid Arthritis »")

    #     button = @driver.find_element(:css, ".Button--Ask")
    #     button.click
    #     wait_for { @driver.find_element(css: '.titlebar').displayed? }
    #     assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/rheumatoid-arthritis/c/question", "Ask a Question linked to #{@driver.current_url} not /rheumatoid-arthritis/c/question")
    #   end
    # end
  end

  def teardown  
    @driver.quit  
  end 
end