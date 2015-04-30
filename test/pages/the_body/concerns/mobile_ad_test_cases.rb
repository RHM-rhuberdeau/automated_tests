module TheBodyMobileAds
  class AdsTestCases
    include ::ActiveModel::Validations

    validate :unique_ads_per_page_view

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
    end

    def unique_ads_per_page_view
      @ads = {}
      @driver.execute_script "window.scrollBy(0, 1000)"
      sleep 0.5
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[1] = @all_ads

      @driver.execute_script "window.scrollBy(0, 1500)"
      sleep 0.5
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
  end
end