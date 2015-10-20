module TheBodyAds
  class Ads
    attr_accessor :url, :ugc, :device, :tile, :sz, :cat, :sc, :ord

    def initialize(ad_string)
      ad_from_string(ad_string)
    end

    def ad_from_string(ad_string)
      hash = parse_ad_into_hash(ad_string)
      hash.keep_if{|k,v| k == "url" || k == "ugc" || k == "device" || k == "tile" || k == "sz" || k == "cat" || k == "sc" || k == "ord"}
      hash.each {|k,v| send("#{k}=",v)}
    end

    def parse_ad_into_hash(ad_string)
      ad_string = ad_string.to_s
      array = ad_string.split(';')
      hash = {}
      hash['url'] = array.delete_at(0)
      array.each do |a|
        b = a.split('=')
        hash[b[0]] = b.last
      end
      hash
    end
  end
end