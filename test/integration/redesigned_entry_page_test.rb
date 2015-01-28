require_relative '../minitest_helper' 
require_relative '../pages/redesign_entry_page'

class RedesignedEntryPageTest < MiniTest::Test
  context "a redesigned Shareposts Entry page" do 
  	setup do
  	  fire_fox_with_secure_proxy
      @proxy.new_har
  	  @page = ::RedesignEntryPage.new(@driver, @proxy)
  	end

  	context "from an expert" do
  	  setup do
  	    visit "#{HC_BASE_URL}/multiple-sclerosis/c/255251/172231/turning-embrace"
  	  end

  	  should "be pharma safe" do
  	    assert_equal(true, @page.pharma_safe?)
  	  end

      should "load the correct analytics file" do
        assert_equal(@page.analytics_file, true)
      end
  	end#from an expert

  	context "from a community member" do
  	  setup do
  		visit "#{HC_BASE_URL}/multiple-sclerosis/c/936913/173745/might-something"
  	  end

  	  should "load the correct analytics file" do
  	    assert_equal(@page.analytics_file, true)
  	  end

  	  should "not be pharma safe" do
  	    assert_equal(false, @page.pharma_safe?)
  	  end
  	end#from a community member
  end#a redesigned Shareposts Entry page

  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end