require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationPageTest < MiniTest::Test
  context "acid reducer" do 
    setup do 
      fire_fox_with_secure_proxy
      io          = File.open('test/fixtures/healthcentral/fdb.yml')
      fixture     = YAML::load_documents(io)
      fdb_fixture = OpenStruct.new(fixture[0]['acid_reducer'])
      head_navigation   = HealthCentralHeader::RedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Acid Reflux",
                                   :related => [''],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = FDB::FDBPage.new(:driver => @driver,:proxy => @proxy,:fixture => fdb_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/acid-reflux/medications/acid-reducer-famotidine-oral-153189"
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