module HealthCentralAssets
  class Assets
    include ::ActiveModel::Validations

    validate :assets_using_correct_host
    validate :no_broken_images
    validate :no_unloaded_assets

    def initialize(args)
      @proxy     = args[:proxy]
      @all_imgs  = args[:imgs]
    end

    def wrong_asset_hosts
      (HealthCentralPage::SITE_HOSTS - [ASSET_HOST])
    end

    def assets_using_correct_host
      wrong_assets = page_wrong_assets
      unless wrong_assets.empty?
        self.errors.add(:base, "there were assets loaded from the wrong environment #{wrong_assets}")
      end
    end

    def page_wrong_assets
      site_urls = @proxy.har.entries.map do |entry|
        if entry.request.url.include?("healthcentral")
          entry.request.url
        end
      end

      site_urls = site_urls.compact

      wrong_assets_on_page = site_urls.map do |site_url|
        if url_has_wrong_asset_host(site_url)
          site_url
        end
      end

      wrong_assets_on_page.compact
    end

    def url_has_wrong_asset_host(url)
      bad_host = wrong_asset_hosts.map do |host_url|
        if url.index(host_url) == 0
          true
        end
      end
      bad_host.compact.length > 0
    end

    def no_unloaded_assets
      unloaded_assets = page_unloaded_assets.compact
      if unloaded_assets.empty? == false
        self.errors.add(:base, "there were unloaded assets #{unloaded_assets}")
      end
    end

    def page_unloaded_assets
      @unloaded_assets ||= @proxy.har.entries.map do |entry|
         if (entry.request.url.split('.com').first.include?("#{HC_BASE_URL}") || entry.request.url.split('.com').first.include?("#{HC_DRUPAL_URL}") ) && entry.response.status != 200
           entry.request.url
        end
      end
      @unloaded_assets.compact
    end

    def url_has_wrong_asset_host(url)
      bad_host = wrong_asset_hosts.map do |host_url|
        if url.index(host_url) == 0
          true
        end
      end
      bad_host.compact.length > 0
    end

    def right_assets
      right_assets = @proxy.har.entries.map do |entry|
        if entry.request.url.include?(ASSET_HOST)
          entry.request.url
        end
      end
      right_assets.compact
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