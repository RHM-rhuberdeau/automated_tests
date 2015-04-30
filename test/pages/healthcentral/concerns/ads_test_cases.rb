module HealthCentralAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view
    validate :correct_ad_site
    validate :correct_ad_categories

    def initialize(args)
      @driver                 = args[:driver]
      @proxy                  = args[:proxy]
      @url                    = args[:url]
      @ad_site                = args[:ad_site]
      @expected_ad_site       = args[:expected_ad_site]
      @ad_categories          = args[:ad_categories]
      @expected_ad_categories = args[:expected_ad_categories]
    end

    def unique_ads_per_page_view
      @ads = {}
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[1] = @all_ads

      visit @url
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[2] = @all_ads - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| HealthCentralAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| HealthCentralAds::Ads.new(ad) }

      ord_values_1 = ads_from_page1.collect(&:ord).uniq
      ord_values_2 = ads_from_page2.collect(&:ord).uniq

      unless ord_values_1.length == 1
        self.errors.add(:base, "Ads on the first view had multiple ord values: #{ord_values_1}")
      end
      unless ord_values_2.length == 1
        self.errors.add(:base, "Ads on the second view had multiple ord values: #{ord_values_2}")
      end
      unless (ord_values_1[0] != ord_values_2[0])
        self.errors.add(:base, "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end
    end

    def correct_ad_site
      unless @ad_site == @expected_ad_site
        self.errors.add(:base, "ad_site was #{@ad_site} not #{@expected_ad_site}")
      end
    end

    def correct_ad_categories
      unless @ad_categories == @expected_ad_categories
        self.errors.add(:base, "ad_categories was #{@ad_categories} not #{@expected_ad_categories}")
      end
    end
  end
end