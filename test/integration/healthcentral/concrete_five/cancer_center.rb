require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/concrete_five_page'

class CancerCenterTest < MiniTest::Test
  context "The cancer center page" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/concrete_five.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['cancer_center'])
      @page           = HealthCentralConcreteFive::ConcreteFivePage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture)
      @url            = "#{MED_BASE_URL}/cecs/cf/cancer-center" 
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
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end