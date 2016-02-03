require "rest-client"

module HealthCentralAssets
  class Assets
    include ::ActiveModel::Validations
    include Capybara::DSL

    KNOWN_PROBLEMS = ["/assets/dne.js", "/common/survey/jquery.cookie.js", "/common/images/small-right-arrow-gray.png",
                      "m/common/polyfills/respond_js/respond.proxy.js"]

    validate :assets_using_correct_host
    validate :no_broken_images
    validate :not_using_old_pipeline

    def initialize(args)
      @base_url         = args[:base_url]
      @host             = args[:host] || ASSET_HOST
      @network_traffic  = args[:network_traffic]
      @network_traffic  = @network_traffic.compact
      #Lets make sure the page has stopped loading
      #This way we don't have to worry about additional assets loading during the test
      begin
        execute_script "window.stop();"
      rescue Timeout::Error, Net::ReadTimeout
      end
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
      
      @network_traffic.each do |entry|
        unless entry.empty?
          entry = entry.first
          if ( entry.first.index(@host) == 0 && entry.last == 200 )
            @good_assets << entry.first
          end
          if ( entry.first.index(@host) == 0 && entry.last != 200 )
            unless entry.first == @base_url || is_known_problem(entry.first)
              @unloaded_assets << entry.first
            end
          end
          if has_wrong_host(entry.first) == true
            @bad_assets << entry.first unless is_known_problem(entry.first)
          end
        end
      end

      unless @good_assets.length > 0
        self.errors.add(:assets, "The page did not load any assets: #{@good_assets} #{@bad_assets} #{@unloaded_assets}")
      end
      unless @bad_assets.length == 0
        self.errors.add(:assets, "There were assets loaded from the wrong environment: #{@bad_assets}")
      end
      unless @unloaded_assets.length == 0
        self.errors.add(:assets, "There were unloaded assets: #{@unloaded_assets}")
      end
    end

    def not_using_old_pipeline
      bad_calls   = []
      good_calls  = []
      all_calls   = []
      @network_traffic.map do |entry|
        unless entry.empty?
          entry = entry.first
          if entry.first.include?("healthcentral") && entry.first.include?("/assets_pipeline/")
            bad_calls << entry.first
          end
          if entry.first.include?("healthcentral") && !entry.first.include?("/assets_pipeline/")
            good_calls << entry.first
          end
        end
      end

      unless bad_calls.compact.empty?
        self.errors.add(:assets, "There were calls to the old pipeline #{bad_calls}")
      end
      unless good_calls.length >= 1
        self.errors.add(:assets, "There were no calls to the current assets pipeline")
      end
    end

    def no_broken_images
      images = all('img')
      image_urls = images.collect {|x| x[:src] }.compact
      
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

      if image_urls.empty?
        self.errors.add(:assets, "No images were loaded on the page")
      end
      unless broken_images.empty?
        self.errors.add(:assets, "#{broken_images.length} broken images on the page: #{broken_images}")
      end
    end
  end
end