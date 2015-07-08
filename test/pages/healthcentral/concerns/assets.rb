module HealthCentralAssets
  class Assets
    include ::ActiveModel::Validations

    validate :assets_using_correct_host
    validate :no_broken_images
    validate :no_unloaded_assets

    def initialize(args)
      @proxy     = args[:proxy]
      @driver    = args[:driver]
    end

    def wrong_asset_hosts
      (HealthCentralPage::SITE_HOSTS - [ASSET_HOST])
    end

    def assets_using_correct_host
      wrong_assets = []
      @proxy.har.entries.map do |entry|
        if entry.request.url.include?("healthcentral")
          wrong_asset_hosts.each do |wrong_host|
            if entry.request.url.index(wrong_host) == 0
              wrong_assets << entry.request.url
            end
          end
        end
      end

      unless wrong_assets.empty?
        self.errors.add(:base, "there were assets loaded from the wrong environment #{wrong_assets}")
      end
    end

    def no_unloaded_assets
      unloaded_assets = page_unloaded_assets.compact
      if unloaded_assets.empty? == false
        self.errors.add(:base, "there were unloaded assets #{unloaded_assets}")
      end
    end

    def page_unloaded_assets
      unloaded_assets = @proxy.har.entries.map do |entry|
         if entry.request.url.include?("#{ASSET_HOST}") && entry.response.status != 200
           entry.request.url
        end
      end
      unloaded_assets.compact
    end

    def no_broken_images
      images = @driver.find_elements(:tag_name => "img")
      broken_images = images.reject do |image|
        @driver.execute_script("return arguments[0].complete && typeof arguments[0].naturalWidth != \"undefined\" && arguments[0].naturalWidth > 0", image)
      end
    end
  end
end