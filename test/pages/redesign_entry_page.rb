require_relative './healthcentral_page'

class RedesignEntryPage < HealthCentralPage
  attr_reader :driver, :proxy

  def initialize(driver,proxy, fixture)
  	@driver  = driver
    @proxy   = proxy
    @fixture = fixture
  end

  def analytics_file
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