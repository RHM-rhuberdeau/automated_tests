require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationsIndexPageTest < MiniTest::Test
  context "acid reflux" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end