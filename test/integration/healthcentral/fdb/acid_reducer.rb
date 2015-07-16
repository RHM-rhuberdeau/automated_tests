require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_page'

class FdbMedicationPageTest < MiniTest::Test
  context "acid reducer" do 
    setup do 
      
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end