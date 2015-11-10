module TheBodyAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :correct_ad_site
    validate :correct_ad_categories
    validate :exclusion_cat
    validate :ugc
    validate :thcn_content_type
    validate :thcn_super_cat
    validate :thcn_category
    validate :sponsor_kw 

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
      if exclusion_cat.include?("javascript error")
        exclusion_cat = ''
      end
      unless exclusion_cat == @exclusion_cat
        self.errors.add(:ads, "EXCLUSION_CAT was #{exclusion_cat} not #{@exclusion_cat}")
      end
    end

    def ugc
      ugc_values  =  []

      @proxy.har.entries.each do |entry|
        if entry.request.url.include?('ad.doubleclick.net/N3965')
          ugc_values << entry.request.url.split('ugc=').last.split(';').first
        end
        has_file = true if entry.request.url.include?('namespace.js')
      end

      ugc_values = ugc_values.uniq.to_s
      unless ugc_values == @ugc
        self.errors.add(:ads, "ugc was #{ugc_values} not #{@ugc}")
      end
    end

    def thcn_content_type
      thcn_content_type = evaluate_script "THCN_CONTENT_TYPE"
      if thcn_content_type.include?("javascript error")
        thcn_content_type = ''
      end
      unless thcn_content_type == @thcn_content_type
        self.errors.add(:ads, "thcn_content_type was #{thcn_content_type} not #{@thcn_content_type}")
      end
    end

    def thcn_super_cat
      thcn_super_cat = evaluate_script "THCN_SUPER_CAT"
      if thcn_super_cat.include?("javascript error")
        thcn_super_cat = ''
      end
      unless thcn_super_cat == @thcn_super_cat
        self.errors.add(:ads, "thcn_super_cat was #{thcn_super_cat} not #{@thcn_super_cat}")
      end
    end

    def thcn_category
      thcn_category = evaluate_script "THCN_CATEGORY"
      if thcn_category.include?("javascript error")
        thcn_category = ''
      end
      unless thcn_category == @thcn_category
        self.errors.add(:ads, "thcn_category was #{thcn_category} not #{@thcn_category}")
      end
    end

    def sponsor_kw 
      sponsor_kw = evaluate_script "SPONSOR_KW"
      if sponsor_kw.include?("javascript error")
        sponsor_kw = ''
      end
      unless sponsor_kw == @sponsor_kw
        self.errors.add(:ads, "sponsor_kw was #{sponsor_kw} not #{@sponsor_kw}")
      end
    end
  end

  class DesktopAds < AdsTestCases
    validate :unique_ads_per_page_view

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
    end

    def unique_ads_per_page_view
      @ads = {}
      @all_ads = TheBodyPage.get_all_ads(@proxy)
      @ads[1] = @all_ads

      visit @url
      sleep 1
      @all_ads = TheBodyPage.get_all_ads(@proxy)
      @ads[2] = @all_ads - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| TheBodyAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| TheBodyAds::Ads.new(ad) }

      ord_values_1 = ads_from_page1.collect(&:ord).uniq
      ord_values_2 = ads_from_page2.collect(&:ord).uniq

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
  end

  class LazyLoadedAds < AdsTestCases

    # validate :one_ad_per_trigger_point
    validate :unique_ord_values
    validate :tile_values

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
      @ads                    = []
      trigger_all_ads
      create_ads_from_ad_calls
    end

    def trigger_all_ads
      # wait_for { @driver.find_element(:css, @trigger).displayed? }
      # trigger_points = @driver.find_elements(:css, @trigger)

      # trigger_points.each_with_index do |node, index|
      #   @proxy.new_har
      #   if index == 0
      #     distance = node.location.y
      #   else
      #     previous_node = trigger_points[index - 1]
      #     distance = node.location.y - previous_node.location.y
      #   end
      #   if distance > 0
      #     @driver.execute_script("window.scrollBy(0, #{distance});")
      #     sleep 0.5
      #     ads = TheBodyPage.get_all_ads(@proxy)
      #     @ad_calls[index + 1] = ads
      #   end
      # end
      scroll_to_bottom_of_page
      sleep 0.5
      @ad_calls = TheBodyPage.get_all_ads(@proxy)
    end

    def create_ads_from_ad_calls
      # @ad_calls.each do |key, value|
      #   @ads[key] = @ad_calls[key].map { |ad_call| TheBodyAds::Ads.new(ad_call) }
      # end
      @ad_calls.each_with_index do |ad_call, index|
        @ads[index] = TheBodyAds::Ads.new(ad_call)
      end
    end

    def one_ad_per_trigger_point
      @ad_calls.each do |k, v|
        unless @ad_calls[k].length == 1
          self.errors.add(:ads, "Trigger point #{k} ad calls #{v.length} ad calls")
        end
      end
    end

    def unique_ord_values
      ord_values = []
      # @ads.each do |key, value|
      #   ord_values << @ads[key].map { |x| x.ord }
      # end
      # ord_values  = ord_values.flatten(2)
      @ads.each do |ad|
        ord_values << ad.ord
      end
      new_array   = ord_values.uniq
      unless ord_values.length == new_array.length
        self.errors.add(:ads, "There were duplicate ord values")
      end
    end

    def tile_values
      tile_values = []
      # @ads.each do |key, value|
      #   tile_values << @ads[key].map { |x| x.tile }
      # end
      @ads.each do |ad|
        tile_values << ad.tile
      end
      # tile_values = tile_values.flatten(2)
      new_array   = tile_values.uniq 
      unless new_array.length == 1
        self.errors.add(:ads, "There were multiple tile values: #{new_array}")
      end
      unless new_array.first.to_i == 1
        self.errors.add(:ads, "Each lazy loaded ad did not have a tile of 1: #{new_array}")
      end
    end
  end
end