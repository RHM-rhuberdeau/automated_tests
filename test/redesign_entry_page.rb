class RedesignEntryPage
  attr_reader :driver

  def initialize(driver)
  	@driver = driver
  end

  def analytics_file
  	driver.page_source.include?("/sites/all/modules/custom/assets_pipeline/public/js/namespace.js")
  end

  def pharma_safe?
  	driver.execute_script("return EXCLUSION_CAT") != 'community'
  end
end