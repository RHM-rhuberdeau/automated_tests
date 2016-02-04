require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/concrete_five_page'

class MedtronicPageTest< MiniTest::Test
  context "a Medtronic page" do 
    include Capybara::DSL

    setup do 
      capybara_with_phantomjs
      io              = File.open('test/fixtures/healthcentral/concrete_five.yml')
      fixture         = YAML::load_documents(io)
      @fixture        = OpenStruct.new(fixture[0]['medtronic'])
      @page           = HealthCentralConcreteFive::ConcreteFivePage.new(:driver =>@driver,:proxy => @proxy, :fixture => @fixture)
      @url            = "#{MED_BASE_URL}/cecs/cf/medtronic" + "?foo=#{rand(36**8).to_s(36)}"
      preload_page @url
      visit @url
    end

    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do
        network_traffic = get_network_traffic  
        assets = @page.assets(:base_url => @url, :host => MED_BASE_URL, :network_traffic => network_traffic)
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
        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      end
    end
  end#a Medtronic page

  def teardown  
     Capybara.reset_sessions!
  end  
end