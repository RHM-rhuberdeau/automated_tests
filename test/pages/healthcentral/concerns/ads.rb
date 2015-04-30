module HealthCentralAds
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
      # hash ={ url: array[0], ugc: array[1].split('=').last, device: array[4].split('=').last, tile: array[7].split('=').last, sz: array[8].split('sz=').last, cat: array[11].split('=').last, sc: array[10].split('=').last, ord: array.last.split('=').last}
      hash
    end
  end
end