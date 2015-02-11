require_relative './healthcentral_page'

class MyMomentPage < HealthCentralPage
  attr_reader :driver, :proxy

  def initialize(driver, proxy)
    @driver = driver
    @proxy  = proxy
    @ads  = []
  end

  def ads_on_page(args)
    all_ads = get_all_ads
    if all_ads.length > args[:length]
      all_ads = all_ads[args[:start], args[:length]]
    end

    ads = create_ads(all_ads)
    ads
  end

  def get_all_ads
    ad_calls = proxy.har.entries.map do |entry|
      if entry.request.url.include?('ad.doubleclick.net/N3965')
        entry.request.url
      end
    end
    ad_calls.compact
  end

  def create_ads(ads)
    new_ads = ads.map do |ad|
      HealthCentralAds.new(ad)
    end
    new_ads
  end

  def ugc
    ad_calls   = []
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