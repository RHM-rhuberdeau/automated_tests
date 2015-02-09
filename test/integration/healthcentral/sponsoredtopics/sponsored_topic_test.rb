require_relative '../minitest_helper' 

class SponsoredTopicTest < MiniTest::Test
  context "a sponsored collection" do 
  	setup do
  	  firefox
  	end

  	context "merck" do
  	  setup do
  	  	visit "#{HC_BASE_URL}/skin-cancer/d/treatment/stage-iv-melanoma?ic=recch"
  	  end

	  should "have an adsite value of cm.own.tcc" do
	  	ad_site = evaluate_script("AD_SITE")
	  	assert_equal(true, (ad_site == "cm.own.tcc"))
	  end

	  should "have at least one ad_category value that is alpha numeric" do
	  	ad_categories = evaluate_script "AD_CATEGORIES"
	  	assert_equal(true, (ad_categories.compact.length >= 1))
	  	assert_equal(false, (ad_categories.first =~ /^\w+$/).nil?)
	  end

	  should "have an evar21 value of ST_Merck_Stage" do
	  	@driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
	  	second_window = @driver.window_handles.last
	  	sponsor_name = evaluate_script("rhm.vars.pageData.sponsor_name")
	  	sponsor_condition = evaluate_script("rhm.vars.pageData.sponsor_condition")
      assert_equal(false, sponsor_name.nil?)
      assert_equal(false, sponsor_condition.nil?)
	  	sleep 2

	  	@driver.switch_to.window second_window
	  	omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
	  	assert_equal(true, omniture_text.include?("eVar21 ST_#{sponsor_name}_#{sponsor_condition}"), "#{omniture_text}")
	  end
	end#merck
	context "understanding-migraines" do
	  setup do
	  	visit "#{HC_BASE_URL}/migraine/d/understanding-migraines/taking-control"
	  end

	  should "have an adsite value of cm.own.tcc" do
	  	ad_site = evaluate_script("AD_SITE")
	  	assert_equal(true, (ad_site == "cm.own.tcc"))
	  end

	  should "have at least one ad_category value that is alpha numeric" do
	  	ad_categories = evaluate_script "AD_CATEGORIES"
	  	assert_equal(true, (ad_categories.compact.length >= 1))
	  	assert_equal(false, (ad_categories.first =~ /^\w+$/).nil?)
	  end

	  should "have an evar21 value of ST_Merck_Stage" do
	  	@driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
	  	second_window = @driver.window_handles.last
	  	sponsor_name = evaluate_script("rhm.vars.pageData.sponsor_name")
	  	sponsor_condition = evaluate_script("rhm.vars.pageData.sponsor_condition")
      assert_equal(false, sponsor_name.nil?)
      assert_equal(false, sponsor_condition.nil?)
	  	sleep 2

	  	@driver.switch_to.window second_window
	  	omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
	  	assert_equal(true, omniture_text.include?("eVar21 ST_#{sponsor_name}_#{sponsor_condition}"), "omniture_text: #{omniture_text}")
	  end
	end#understanding-migraines
  end#a sponsored collection

  def teardown  
    @driver.quit 
  end  
end