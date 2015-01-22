class RedesignEntryPage
  attr_reader :driver, :proxy

  def initialize(driver,proxy)
  	@driver = driver
    @proxy  = proxy
  end

  def analytics_file
  	# driver.page_source.include?("/sites/all/modules/custom/assets_pipeline/public/js/namespace.js")
    has_file = false
    proxy.har.entries.each do |entry|
      if entry.request.url.include?('/sites/all/modules/custom/assets_pipeline/public/js/namespace.js')
        has_file = true
      end
    end
    has_file
  end

  def pharma_safe?
  	driver.execute_script("return EXCLUSION_CAT") != 'community'
  end
end