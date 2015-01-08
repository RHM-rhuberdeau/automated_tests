class RedesignQuestionPage
  attr_reader :driver, :proxy

  def initialize(driver, proxy)
  	@driver = driver
  	@proxy	= proxy
  end

  def analytics_file
  	driver.page_source.include?("/sites/all/modules/custom/assets_pipeline/public/js/namespace.js")
  end

  def pharma_safe?
  	(driver.execute_script("return EXCLUSION_CAT") != 'community') && (driver.execute_script("return pharmaSafe") == true)
  end

  def ugc
  	ad_calls 	 = []
  	ugc_values   =  []

  	proxy.har.entries.find do |entry|
	  if entry.request.url.include?('ad.doubleclick.net/N3965')
	  	ad_calls   << entry.request.url
	  	ugc_values << entry.request.url.split('ugc=').last.split(';').first
	  end
  	end

  	ugc_values.uniq.to_s
  end
end