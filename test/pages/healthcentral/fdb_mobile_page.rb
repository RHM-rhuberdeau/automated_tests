require_relative './healthcentral_page'

module FDB
  class FDBMobilePage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
    end
  end

  class LazyLoadedAds < HealthCentralAds::LazyLoadedAds
    def unique_ads_per_page_view
      scroll1 = 750
      scroll2 = 1500
      @ads = {}
      @driver.execute_script "window.scrollBy(0, #{scroll1})"
      sleep 1
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[1] = @all_ads
      @driver.execute_script "window.scrollBy(0, #{scroll2})"
      sleep 1
      @all_ads = HealthCentralPage.get_all_ads(@proxy)
      @ads[2] = @all_ads - @ads.flatten(2)

      ads_from_page1 = @ads[1].map { |ad| HealthCentralAds::Ads.new(ad) }
      ads_from_page2 = @ads[2].map { |ad| HealthCentralAds::Ads.new(ad) }

      ord_values_1 = ads_from_page1.collect(&:ord).uniq
      ord_values_2 = ads_from_page2.collect(&:ord).uniq

      unless ads_from_page1.length == 2
        self.errors.add(:ads, "Wrong number of ads were loaded on first scroll. Expeced 1 got #{ads_from_page1.length}")
      end
      unless ads_from_page2.length == 2
        self.errors.add(:ads, "Wrong number of ads were loaded on second scroll. Expeced 1 got #{ads_from_page2.length}")
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

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :head_navigation
    validate :footer

    def initialize(args)
      @head_navigation = args[:head_navigation]
      @footer          = args[:footer]
    end

    def head_navigation
      @head_navigation.validate
      unless @head_navigation.errors.empty?
        self.errors.add(:head_navigation, @head_navigation.errors.values.first)
      end
    end

    def footer
      @footer.validate
      unless @footer.errors.empty?
        self.errors.add(:footer, @footer.errors.values.first)
      end
    end
  end
end