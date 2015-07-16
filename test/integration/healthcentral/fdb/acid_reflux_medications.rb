require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationsIndexPageTest < MiniTest::Test
  context "acid reflux" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io          = File.open('test/fixtures/healthcentral/fdb.yml')
      fixture     = YAML::load_documents(io)
      fdb_fixture = OpenStruct.new(fixture[0]['acid_reflux'])
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end