require 'active_model'
require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/ads_tests_cases'
require_relative './concerns/header'
require_relative './concerns/footer'


class TheBodyPage
  attr_reader :driver, :proxy, :slides, :ords
  include TheBodyOmniture 
  include TheBodyAssets 
  include TheBodyAds 
  include TheBodyHeader
  include TheBodyFooter
                    
  SITE_HOSTS = ["http://uat.thebody.", "http://qa1.thebody.","http://qa2.thebody.","http://qa3.thebody.", "http://qa4.thebody.", "http://www.thebody.", "http://alpha.thebody.", "http://stage.thebody."]

  def functionality
    raise NotImplementedError
  end

  def assets
    Assets.new(:proxy => @proxy, :driver => @driver)
  end

  def omniture
    open_omniture_debugger
    omniture_text = get_omniture_from_debugger
    omniture = TheBodyOmniture::Omniture.new(omniture_text, @fixture)
  end 

  def global_test_cases
    GlobalTestCases.new(:driver => @driver)
  end

  def has_correct_title?
    title = @driver.title
    title.scan(/^[^\-]*-[\s+\w+]+/).length == 1
  end

  def self.get_all_ads(proxy)
    @proxy = proxy
    ad_calls = @proxy.har.entries.map do |entry|
      if entry.request.url.include?('ad.doubleclick.net/N3965')
        entry.request.url
      end
    end
    ad_calls.compact
  end
end




