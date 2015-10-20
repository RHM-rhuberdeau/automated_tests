module TheBodyAssets
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
        if ( entry.request.url.index(THE_BODY_ASSET_HOST) == 0 && entry.response.status == 200 )
          @good_assets << entry.request.url
        end
        if ( entry.request.url.index(THE_BODY_ASSET_HOST) == 0 && entry.response.status != 200 )
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
      ( TheBodyPage::SITE_HOSTS - [THE_BODY_ASSET_HOST] ) == ( TheBodyPage::SITE_HOSTS - [url] )
    end

    def no_broken_images
      images = @driver.find_elements(:tag_name => "img")
      
      image_urls = images.collect do |image|
        begin
           if image.attribute('src')
            image.attribute('src').gsub(' ','')
          end
        rescue
          Selenium::WebDriver::Error::StaleElementReferenceError
        end
      end

      image_urls = image_urls.select do |x|
        x.class == "String"
      end
      
      broken_images = image_urls.reject do |url|
        if url.length > 4
          begin
            RestClient.get url do |response, request, result|
              response.code == 200
            end
          rescue URI::InvalidURIError
          end
        end
      end

      unless broken_images.empty?
        self.errors.add(:assets, "#{broken_images.length} broken images on the page: #{broken_images}")
      end
    end
  end
end