module BerkeleyAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view
    validate :correct_ad_site
    validate :correct_ad_categories
    validate :thcn_content_type
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
      @scroll1                = args[:scroll1] || 1500
      @scroll2                = args[:scroll2] || 1500
    end

    def unique_ads_per_page_view
      @ads = {}
      all_ads = BerkeleyPage.get_all_ads(@proxy)
      @ads[1] = all_ads

      visit @url
      sleep 5
      all_ads2 = BerkeleyPage.get_all_ads(@proxy)
      @ads[2] = all_ads2 - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| BerkeleyAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| BerkeleyAds::Ads.new(ad) }

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

    def thcn_content_type
      thcn_content_type = evaluate_script "THCN_CONTENT_TYPE"
      unless thcn_content_type == @thcn_content_type
        self.errors.add(:ads, "THCN_CONTENT_TYPE was #{thcn_content_type} not #{@thcn_content_type}")
      end
    end

    def ugc
      has_file    = false
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
      unless has_file == true
        self.errors.add(:ads, "namespace.js was not loaded")
      end
    end
  end

  class LazyLoadedAds < AdsTestCases
    include ::ActiveModel::Validations

    def unique_ads_per_page_view
      @ads = {}
      @driver.execute_script "window.scrollBy(0, #{@scroll1})"
      sleep 1
      @all_ads = BerkeleyPage.get_all_ads(@proxy)
      @ads[1] = @all_ads
      @driver.execute_script "window.scrollBy(0, #{@scroll2})"
      sleep 1
      @all_ads = BerkeleyPage.get_all_ads(@proxy)
      @ads[2] = @all_ads - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| BerkeleyAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| BerkeleyAds::Ads.new(ad) }

      ord_values_1 = ads_from_page1.collect(&:ord).uniq
      ord_values_2 = ads_from_page2.collect(&:ord).uniq

      unless ads_from_page1.length == 1
        self.errors.add(:ads, "Wrong number of ads were loaded on first scroll. Expeced 1 got #{ads_from_page1.length}")
      end
      unless ord_values_1.length == 1
        self.errors.add(:ads, "First set of lazy loaded ads had multiple ord values: #{ord_values_1}")
      end
      unless ord_values_2.length == 1
        self.errors.add(:ads, "Ads on the second view had multiple ord values: #{ord_values_2}")
      end
      unless (ord_values_1[0] != ord_values_2[0])
        self.errors.add(:ads, "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end
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