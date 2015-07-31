require 'active_model'
require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/slide'
require_relative './concerns/ads_test_cases'
require_relative './concerns/header'
require_relative './concerns/footer'
require_relative './concerns/seo'

class BerkeleyPage
  include BerkeleyOmniture 
  include BerkeleyAssets 
  include BerkeleyAds 
  include BerkeleyHeader
  include BerkeleySeo

  SITE_HOSTS = ["http://bw3.hcaws.", "http://qa1.berkeleywellness.","http://qa2.berkeleywellness.","http://qa3.berkeleywellness.", "http://qa4.berkeleywellness.", "http://www.berkeleywellness.", "http://alpha.berkeleywellness.", "http://stage.berkeleywellness."]

  def omniture
    open_omniture_debugger
    omniture_text = get_omniture_from_debugger
    begin
      omniture = BerkeleyOmniture::Omniture.new(omniture_text, @fixture)
    rescue BerkeleyOmniture::OmnitureIsBlank
      omniture = OpenStruct.new(:errors => OpenStruct.new(:messages => {:omniture => "Omniture was blank"}), :validate => '')
    end
  end 

  def assets
    BerkeleyAssets::Assets.new(:driver => @driver, :proxy => @proxy)
  end

  def global_test_cases
    GlobalTestCases.new(:driver => @driver, :header => @header, :footer => @footer)
  end

  def seo 
    BerkeleySeo::Seo.new(:driver => @driver)
  end

  def functionality
    raise NotImplementedError
  end

  def self.get_all_ads(proxy)
    @proxy = proxy
    ad_calls = @proxy.har.entries.map do |entry|
      if entry.request.url.include?('ad.doubleclick.net/N3965')
        entry.request.url
      end
    end

    if ad_calls.compact.length < 3
      sleep 2
      ad_calls = @proxy.har.entries.map do |entry|
        if entry.request.url.include?('ad.doubleclick.net/N3965')
          entry.request.url
        end
      end
    end
    
    ad_calls.compact
  end

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :header
    validate :footer

    def initialize(args)
      @header = args[:header]
      @footer = args[:footer]
    end

    def header
      @header.validate
      unless @header.errors.empty?
        self.errors.add(:header, @header.errors.values.first)
      end
    end

    def footer
      @footer.validate
      unless @footer.errors.empty?
        self.errors.add(:footer, @footer.errors.values.first)
      end
    end
  end
end