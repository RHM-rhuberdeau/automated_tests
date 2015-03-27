require_relative '../minitest_helper' 
require_relative '../pages/concrete5_page'

class MedtronicPageTest< MiniTest::Test
  context "a Medtronic page" do 
  	setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::Concrete5::Concrete5Page.new(@driver, @proxy)
      visit "#{MED_BASE_URL}/cecs/cf/medtronic"
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
  end#a Medtronic page

  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end