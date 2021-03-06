require_relative '../../../minitest_helper'
require_relative '../../../pages/berkeley/home_page'

class BerkeleyHomePage < MiniTest::Test
  context "Berkeley Home Page" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      header            = BerkeleyHeader::DesktopHeader.new(:driver => @driver)
      footer            = BerkeleyFooter::DesktopFooter.new(:driver => @driver)
      @page             = Berkeley::BerkeleyHomePage.new(:driver =>@driver, :proxy => @proxy, :header => header, :footer => footer)
      @url               = BW_BASE_URL + $_cache_buster
      visit @url
    end

    ##################################################################
    ################ FUNCTIONALITY ###################################
    context "when functioning properly" do 
      should "not have any errors" do 
        functionality = @page.functionality(:driver => @driver)
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
      should "have valid seo" do 
        seo = @page.seo
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        ad_site           = 'cm.pub.berkwell'
        ad_categories     = ["homepage"]
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = ""
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

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      should "have passing global test cases" do 
        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")
      end
    end
  end

  # context "Popular article listing" do 
  #   setup do 
  #     firefox
  #     visit "#{BW_BASE_URL}/popular-article-listing"
  #   end

  #   should "have a noindex tag" do 
  #     no_index = @driver.find_elements(:css, "meta[name='robots']")
  #     assert_equal(false, no_index.empty?, "noindex tag not found: #{no_index.inspect}")
  #   end
  # end#Popular article listing

  def teardown  
    cleanup_driver_and_proxy
  end 
end