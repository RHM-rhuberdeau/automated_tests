module HealthCentralAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view
    validate :correct_ad_site
    validate :correct_ad_categories
    validate :exclusion_cat
    validate :sponsor_kw
    validate :thcn_content_type
    validate :thcn_super_cat
    validate :thcn_category
    validate :ugc

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @url                    = args[:url]
      @ad_site                = args[:ad_site]
      @ad_categories          = args[:ad_categories]
      @exclusion_cat          = args[:exclusion_cat]
      @sponsor_kw             = args[:sponsor_kw]
      @thcn_content_type      = args[:thcn_content_type]
      @thcn_super_cat         = args[:thcn_super_cat]
      @thcn_category          = args[:thcn_category]
      @ugc                    = args[:ugc]
      @ads                    = {}
      @ad_calls               = {}
      collect_ads_from_two_page_loads
    end

    def collect_ads_from_two_page_loads
      page_one_ad_calls = HealthCentralPage.get_all_ads(@proxy)
      ads_from_page1 = page_one_ad_calls.map { |ad| HealthCentralAds::Ads.new(ad) }

      # Put sleep calls around setting up a new har file to avoid race conditions
      sleep 0.25
      @proxy.new_har
      sleep 0.25

      visit @url
      page_two_ad_calls = HealthCentralPage.get_all_ads(@proxy)
      ads_from_page2 = page_two_ad_calls.map { |ad| HealthCentralAds::Ads.new(ad) }

      #Do this at the end incase there's any errors
      @ads[:page_one_ads] = ads_from_page1
      @ads[:page_two_ads] = ads_from_page2
      @ad_calls[:page_one_ad_calls] = page_one_ad_calls
      @ad_calls[:page_two_ad_calls] = page_two_ad_calls
    end

    def unique_ads_per_page_view
      ord_values_1 = @ads[:page_one_ads].collect(&:ord).uniq
      ord_values_2 = @ads[:page_two_ads].collect(&:ord).uniq

      unless ord_values_1.length == 1
        self.errors.add(:ads, "Ads on the first view had multiple ord values: #{ord_values_1}")
      end
      unless ord_values_2.length == 1
        self.errors.add(:ads, "Ads on the second view had multiple ord values: #{ord_values_2}")
      end
      unless (ord_values_1[0] != ord_values_2[0])
        self.errors.add(:ads, "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end
    end

    def correct_ad_site
      ad_site = evaluate_script "AD_SITE"
      unless ad_site == @ad_site
        self.errors.add(:ads, "ad_site was #{ad_site} not #{@ad_site}")
      end
    end

    def correct_ad_categories
      ad_categories = evaluate_script "AD_CATEGORIES"
      unless ad_categories == @ad_categories
        self.errors.add(:ads, "ad_categories was #{ad_categories} not #{@ad_categories}")
      end
    end

    def exclusion_cat
      exclusion_cat = evaluate_script "EXCLUSION_CAT"
      unless exclusion_cat == @exclusion_cat
        self.errors.add(:ads, "EXCLUSION_CAT was #{exclusion_cat} not #{@exclusion_cat}")
      end
    end

    def sponsor_kw
      sponsor_kw = evaluate_script "SPONSOR_KW"
      unless sponsor_kw == @sponsor_kw
        self.errors.add(:ads, "SPONSOR_KW was #{sponsor_kw} not #{@sponsor_kw}")
      end
    end

    def thcn_content_type
      thcn_content_type = evaluate_script "THCN_CONTENT_TYPE"
      unless thcn_content_type == @thcn_content_type
        self.errors.add(:ads, "THCN_CONTENT_TYPE was #{thcn_content_type} not #{@thcn_content_type}")
      end
    end

    def thcn_super_cat
      thcn_super_cat = evaluate_script "THCN_SUPER_CAT"
      unless thcn_super_cat == @thcn_super_cat
        self.errors.add(:ads, "THCN_SUPER_CAT was #{thcn_super_cat} not #{@thcn_super_cat}")
      end
    end

    def thcn_category
      thcn_category = evaluate_script "THCN_CATEGORY"
      unless thcn_category == @thcn_category
        self.errors.add(:ads, "THCN_CATEGORY was #{thcn_category} not #{@thcn_category}")
      end
    end

    def ugc
      @ads[:page_one_ads].each do |ad|
        unless ad.ugc == @ugc
          self.errors.add(:ads, "Expected ad to have a ugc value of #{@ugc}: #{ad.ad_call}")
        end
      end
      @ads[:page_two_ads].each do |ad|
        unless ad.ugc == @ugc
          self.errors.add(:ads, "Expected ad to have a ugc value of #{@ugc}: #{ad.ad_call}")
        end
      end
    end
  end

  class LazyLoadedAds < AdsTestCases

    validate :one_ad_per_trigger_point
    validate :unique_ord_values
    validate :tile_values
    validate :ugc

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @url                    = args[:url]
      @ad_site                = args[:ad_site]
      @ad_categories          = args[:ad_categories]
      @exclusion_cat          = args[:exclusion_cat]
      @ugc                    = args[:ugc]
      @thcn_content_type      = args[:thcn_content_type]
      @thcn_super_cat         = args[:thcn_super_cat]
      @thcn_category          = args[:thcn_category]
      @sponsor_kw             = args[:sponsor_kw]
      @trigger                = args[:trigger_point]
      @ad_calls               = {}
      @ads                    = {}
      trigger_all_ads
      create_ads_from_ad_calls
    end

    def unique_ads_per_page_view

    end

    def trigger_all_ads
      wait_for { @driver.find_element(:css, @trigger).displayed? }
      trigger_points = @driver.find_elements(:css, @trigger)

      trigger_points.each_with_index do |node, index|
        @proxy.new_har
        if index == 0
          distance = node.location.y
        else
          previous_node = trigger_points[index - 1]
          begin
            distance = node.location.y - previous_node.location.y
          rescue Selenium::WebDriver::Error::UnknownError
            distance = 0
          end
        end
        if distance > 0
          @driver.execute_script("window.scrollBy(0, #{distance});")
          sleep 0.5
          ads = HealthCentralPage.get_all_ads(@proxy)
          @ad_calls[index + 1] = ads
        end
        sleep 0.5
      end
    end

    def create_ads_from_ad_calls
      @ad_calls.each do |key, value|
        @ads[key] = @ad_calls[key].map { |ad_call| HealthCentralAds::Ads.new(ad_call) }
      end
    end

    def one_ad_per_trigger_point
      unless @ad_calls.keys.length >= 1
        self.errors.add(:ads, "No ad calls were made")
      end
      @ad_calls.each do |k, v|
        unless @ad_calls[k].length == 1
          self.errors.add(:ads, "Trigger point #{k} ad calls #{v.length} ad calls")
        end
      end
    end

    def unique_ord_values
      ord_values = []
      @ads.each do |key, value|
        ord_values << @ads[key].map { |x| x.ord }
      end
      ord_values  = ord_values.flatten(2)
      new_array   = ord_values.uniq
      unless ord_values.length == new_array.length
        self.errors.add(:ads, "There were duplicate ord values")
      end
    end

    def tile_values
      tile_values = []
      @ads.each do |key, value|
        tile_values << @ads[key].map { |x| x.tile }
      end
      tile_values = tile_values.flatten(2)
      new_array   = tile_values.uniq 
      unless new_array.length == 1
        self.errors.add(:ads, "There were multiple tile values: #{new_array}")
      end
      unless new_array.first.to_i == 1
        self.errors.add(:ads, "Each lazy loaded ad did not have a tile of 1: #{new_array}")
      end
    end

    def ugc 
      #Go through each ad call and make sure it has the correct ugc value
      #ugc is specific to each article
    end
  end

  class NoAds < AdsTestCases
    include ::ActiveModel::Validations

    def unique_ads_per_page_view

    end

    def ugc
      
    end
  end
end