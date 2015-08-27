require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/home_page'

class BerkeleyExplainerTest < MiniTest::Test
  context "hard look bpa" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{BW_BASE_URL}/healthy-community/environmental-health/article/hard-look-bpa"
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
    @driver.quit  
    @proxy.close
  end 
end