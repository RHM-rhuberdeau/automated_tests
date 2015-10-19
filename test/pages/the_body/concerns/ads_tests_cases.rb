module TheBodyAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view
    validate :correct_ad_site
    validate :correct_ad_categories
    validate :ugc

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @url                    = args[:url]
      @ad_site                = args[:ad_site]
      @ad_categories          = args[:ad_categories]
      @exclusion_cat          = args[:exclusion_cat]
      @ugc                    = args[:ugc]
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
  end

  class LazyLoadedAds
    include ::ActiveModel::Validations

    validate :one_ad_per_trigger_point

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @ad_site                = args[:ad_site]
      @ad_categories          = args[:ad_categories]
      @exclusion_cat          = args[:exclusion_cat]
      @sponsor_kw             = args[:sponsor_kw]
      @thcn_content_type      = args[:thcn_content_type]
      @thcn_super_cat         = args[:thcn_super_cat]
      @thcn_category          = args[:thcn_category]
      @ugc                    = args[:ugc]
      @trigger                = args[:trigger_point]
      @ads                    = {}
      trigger_all_ads
    end

    def trigger_all_ads
      wait_for { @driver.find_elements(:css, @trigger).last.displayed? }
      trigger_points = @driver.find_elements(:css, @trigger)

      trigger_points.each_with_index do |node, index|
        @proxy.new_har
        if index == 0
          distance = node.location.y
        else
          previous_node = trigger_points[index - 1]
          distance = node.location.y - previous_node.location.y
        end
        if distance > 0
          @driver.execute_script("window.scrollBy(0, #{distance});")
          sleep 0.5
          ads = TheBodyPage.get_all_ads(@proxy)
          @ads[index + 1] = ads
        end
      end
    end

    def one_ad_per_trigger_point
      @ads.each do |k, v|
        unless @ads[k].length == 1
          self.errors.add(:ads, "Trigger point #{k} ad calls #{v.length} ad calls")
        end
      end
    end
  end
end