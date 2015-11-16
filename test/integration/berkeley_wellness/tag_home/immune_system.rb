require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/home_page'

class BerkeleyTagHomeTest < MiniTest::Test
  context "immune system" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      @url  = "#{BW_BASE_URL}/immune-system" + "?foo=#{rand(36**8).to_s(36)}"
      @page = Berkeley::BerkeleyHomePage.new(:driver =>@driver, :proxy => @proxy)
      visit @url
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

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site           = 'cm.pub.berkwell'
        ad_categories     = []
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "tags"
        thcn_super_cat    = ""
        thcn_category     = ""
        ads               = Berkeley::BerkeleyHomePage::AdsTestCases.new(:driver => @driver,
                                                                 :proxy => @proxy, 
                                                                 :url => @url,
                                                                 :ad_site => ad_site,
                                                                 :ad_categories => ad_categories,
                                                                 :exclusion_cat => exclusion_cat,
                                                                 :sponsor_kw  => sponsor_kw,
                                                                 :thcn_content_type => thcn_content_type,
                                                                 :thcn_super_cat => thcn_super_cat,
                                                                 :thcn_category => thcn_category,
                                                                 :ugc => "[\"n\"]") 
        ads.validate
        assert_equal(true, ads.errors.empty?, "#{ads.errors.messages}")
      end
    end
  end

  def teardown  
    cleanup_driver_and_proxy
  end 
end