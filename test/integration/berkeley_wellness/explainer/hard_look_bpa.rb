require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/home_page'

class BerkeleyExplainerTest < MiniTest::Test
  context "hard look bpa" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      @url  = "#{BW_BASE_URL}/healthy-community/environmental-health/article/hard-look-bpa" + $_cache_buster
      @page = Berkeley::BerkeleyHomePage.new(:driver =>@driver, :proxy => @proxy)
      visit @url
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

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end
  end

  def teardown  
    cleanup_driver_and_proxy
  end 
end