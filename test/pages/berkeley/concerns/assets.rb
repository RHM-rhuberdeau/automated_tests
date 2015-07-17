module BerkeleyAssets
  class Assets
    include ::ActiveModel::Validations

    validate :assets_using_correct_host
    validate :no_broken_images

    def initialize(args)
      @proxy     = args[:proxy]
      @driver    = args[:driver]
    end

    def assets_using_correct_host
      @good_assets      = []
      @bad_assets       = []
      @unloaded_assets  = []
      
      @proxy.har.entries.each do |entry|
        if ( entry.request.url.index(BW_ASSET_HOST) == 0 && entry.response.status == 200 )
          @good_assets << entry.request.url
        end
        if ( entry.request.url.index(BW_ASSET_HOST) == 0 && entry.response.status != 200 )
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
      ( BerkeleyPage::SITE_HOSTS - [BW_ASSET_HOST] ) == ( BerkeleyPage::SITE_HOSTS - [url] )
    end

    def no_broken_images
      images = @driver.find_elements(:tag_name => "img")
      broken_images = images.reject do |image|
        begin
          @driver.execute_script("return arguments[0].complete && typeof arguments[0].naturalWidth != \"undefined\" && arguments[0].naturalWidth > 0", image)
        rescue Selenium::WebDriver::Error::JavascriptError
          true
        end
      end
    end
  end
end