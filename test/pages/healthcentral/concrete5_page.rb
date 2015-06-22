require_relative './healthcentral_page'

module Concrete5
  class Concrete5Page < HealthCentralPage

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
    end

    SITE_HOSTS = ["http://qa.healthcentral.", "http://qa1.healthcentral.","http://qa2.healthcentral.","http://qa3.healthcentral.", "http://qa4.healthcentral.", "https://secure.healthcentral.", "http://alpha.healthcentral.", "http://stage.healthcentral."]
  end

  class Assets
    include ::ActiveModel::Validations

    validate :assets_using_correct_host
    validate :no_broken_images

    def initialize(args)
      @proxy     = args[:proxy]
      @all_imgs  = args[:imgs]
    end

    def assets_using_correct_host
      @good_assets      = []
      @bad_assets       = []
      @unloaded_assets  = []
      
      @proxy.har.entries.each do |entry|
        if ( entry.request.url.index(Configuration['medtronic']['asset_host']) == 0 && entry.response.status == 200 )
          @good_assets << entry.request.url
        end
        if ( entry.request.url.index(Configuration['medtronic']['asset_host']) == 0 && entry.response.status != 200 )
          @unloaded_assets << entry.request.url
        end
        if has_wrong_host(entry.request.url) == true
          @bad_assets << entry.request.url
        end
      end

      unless @good_assets.length > 0
        self.errors.add(:base, "The page did not load any assets")
      end
      unless @bad_assets.length == 0
        self.errors.add(:base, "There were assets loaded from the wrong environment: #{@bad_assets}")
      end
      unless @unloaded_assets.length == 0
        self.errors.add(:base, "There were unloaded assets: #{@unloaded_assets}")
      end
    end

    def has_wrong_host(url)
      ( Concrete5Page::SITE_HOSTS - [Configuration['medtronic']['asset_host']] ) == ( Concrete5Page::SITE_HOSTS - [url] )
    end

    def no_broken_images
      broken_images = []
      @all_imgs.each do |img|
        broken_images << @proxy.har.entries.find do |entry|
          entry.request.url == img.attribute('src') && entry.response.status == 404
        end
      end
      broken_images = broken_images.compact.collect do |x| 
        x.request.url if (!x.request.url.include?("avatars") && (ENV['TEST_ENV'] != "production")) 
      end
      unless broken_images.compact.empty?
        self.errors.add(:base, "broken images on the page #{broken_images}")
      end
    end
  end
end