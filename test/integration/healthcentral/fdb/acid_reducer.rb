require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationPageTest < MiniTest::Test
  context "acid reducer" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      io = File.open('test/fixtures/healthcentral/fdb.yml')
      fixture           = YAML::load_documents(io)
      topic_fixture     = OpenStruct.new(fixture[0]['acid_reducer'])
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end