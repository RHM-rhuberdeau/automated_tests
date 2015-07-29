require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/concrete_five_page'

class MedtronicPageTest< MiniTest::Test
  context "a Medtronic page" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io              = File.open('test/fixtures/healthcentral/concrete_five.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['medtronic'])
      @page           = HealthCentralConcreteFive::ConcreteFivePage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture)
      @url            = "#{MED_BASE_URL}/cecs/cf/medtronic" 
      visit @url
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

   #########################################################################
   ################### ADS, ANALYTICS, OMNITURE ############################
   context "ads, analytics, omniture" do
     should "not have any errors" do 
       omniture = @page.omniture
       omniture.validate
       assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
     end
   end
  end#a Medtronic page

  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end