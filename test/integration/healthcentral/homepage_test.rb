require_relative '../../minitest_helper' 
require_relative '../../pages/healthcentral/redesign_entry_page'

class HomePageTest < MiniTest::Test 
  context "The HealthCentral Homepage" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}"
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