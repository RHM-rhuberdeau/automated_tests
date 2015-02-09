require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_entry_page'

class EntryPageTest < MiniTest::Test
  context "a community member entry" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::RedesignEntryPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/multiple-sclerosis/c/936913/173745/might-something"
    end

    should "load the correct analytics file" do
      assert_equal(@page.analytics_file, true)
    end

    should "not be pharma safe" do
      assert_equal(false, @page.pharma_safe?)
    end

    should "have the correct title" do 
      assert_equal(true, @page.has_correct_title?)
    end

    should "not have unloaded assets" do 
      assert_equal(false, @page.has_unloaded_assets?, "#{@page.unloaded_assets}")
    end

    should "load assets from the correct environment" do 
      assert_equal(true, @page.wrong_assets.empty?, "wrong assets: #{@page.wrong_assets}")
      assert_equal(false, @page.right_assets.empty?, "right assets empty: #{@page.right_assets}")
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end