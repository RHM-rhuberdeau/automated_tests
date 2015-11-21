require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/subcategory_page'

class IncontinenceSubCategory < MiniTest::Test
  context "incontinence" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/subcategories.yml')
      subcat_fixture = YAML::load_documents(io)
      @subcat_fixture = OpenStruct.new(subcat_fixture[0]['incontinence'])
      footer          = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      header          = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Incontinence",
                                   :related => ["Menopause"],
                                   :driver => @driver)
      @page = ::HealthCentral::SubcategoryPage.new(:driver =>@driver,:proxy => @proxy,:fixture => @subcat_fixture, :head_navigation => header, :footer => footer)
      @url  = "#{HC_BASE_URL}/incontinence/" + $_cache_buster
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
        ad_site        = "cm.ver.incontinence"
        ad_categories  = ["home", "", ""]
        ads            = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => @url,
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "ad_content_type",
                                                            :sponsor_kw => '',
                                                            :thcn_content_type => "Home Page",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Bladder Health",
                                                            :ugc => "n") 
        ads.validate

        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end

    #################################################################
    ################## GLOBAL SITE TESTS ############################
    context "global site requirements" do
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