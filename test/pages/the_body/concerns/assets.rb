module TheBodyAssets
 class Assets
    include ::ActiveModel::Validations

    validate :assets_using_correct_host
    # validate :no_broken_images

    def initialize(args)
      @proxy     = args[:proxy]
      @all_imgs  = args[:imgs]
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
      broken_images = []
      @all_imgs.each do |img|
        @proxy.har.entries.each do |entry|
          if ( entry.request.url == img.attribute('src') && entry.response == 404 )
            broken_images << entry.request.url
          end
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