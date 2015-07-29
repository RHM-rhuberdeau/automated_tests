module HealthCentralAssets
  class Assets
    include ::ActiveModel::Validations

    KNOWN_PROBLEMS = ["/assets/dne.js", "/common/survey/jquery.cookie.js", "/common/images/small-right-arrow-gray.png",
                      "m/common/polyfills/respond_js/respond.proxy.js"]

    validate :assets_using_correct_host
    validate :no_broken_images
    validate :not_using_old_pipeline

    def initialize(args)
      @proxy     = args[:proxy]
      @driver    = args[:driver]
      @base_url  = args[:base_url]
    end

    def wrong_asset_hosts
      (HealthCentralPage::SITE_HOSTS - [ASSET_HOST])
    end

    def has_wrong_host(url)
      wrong_asset_hosts.each do |wrong_host|
        if url.index(wrong_host) == 0
          return true
        end
      end
    end

    def is_known_problem(url)
      KNOWN_PROBLEMS.each do |known_issue|
        return true if url.include?(known_issue) && ENV['TEST_ENV'] != 'production'
      end
    end

    def assets_using_correct_host
      @good_assets      = []
      @bad_assets       = []
      @unloaded_assets  = []
      
      @proxy.har.entries.each do |entry|
        if ( entry.request.url.index(ASSET_HOST) == 0 && entry.response.status == 200 )
          @good_assets << entry.request.url
        end
        if ( entry.request.url.index(ASSET_HOST) == 0 && entry.response.status != 200 )
          unless entry.request.url == @base_url || is_known_problem(entry.request.url)
            @unloaded_assets << entry.request.url
          end
        end
        if has_wrong_host(entry.request.url) == true
          @bad_assets << entry.request.url unless is_known_problem(entry.request.url)
        end
      end

      unless @good_assets.length > 0
        self.errors.add(:assets, "The page did not load any assets")
      end
      unless @bad_assets.length == 0
        self.errors.add(:assets, "There were assets loaded from the wrong environment: #{@bad_assets}")
      end
      unless @unloaded_assets.length == 0
        self.errors.add(:assets, "There were unloaded assets: #{@unloaded_assets}")
      end
    end

    def not_using_old_pipeline
      bad_calls = []
      @proxy.har.entries.map do |entry|
        if entry.request.url.include?("healthcentral") && entry.request.url.include?("/assets_pipeline/")
          bad_calls << entry.request.url
        end
      end
      unless bad_calls.compact.empty?
        self.errors.add(:assets, "There were calls to the old pipeline #{bad_calls}")
      end
    end

    def no_broken_images
      images = @driver.find_elements(:tag_name => "img")
      broken_images = images.reject do |image|
        @driver.execute_script("return arguments[0].complete && typeof arguments[0].naturalWidth != \"undefined\" && arguments[0].naturalWidth > 0", image)
      end
      unless broken_images.empty?
        self.errors.add(:assets, "#{broken_images.length} broken images on the page")
      end
    end
  end
end