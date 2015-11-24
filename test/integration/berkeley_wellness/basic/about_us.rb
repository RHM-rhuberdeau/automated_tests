require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/home_page'

class BerkeleyBlogTest < MiniTest::Test
  context "about us" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{BW_BASE_URL}/about-us#{$_cache_buster}"
      @page = Berkeley::BerkeleyHomePage.new(:driver =>@driver, :proxy => @proxy)
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