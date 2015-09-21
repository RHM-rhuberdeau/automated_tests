module HealthCentralSeo
  class Seo
    include ::ActiveModel::Validations

    validate :only_one_h1
    validate :page_title
    validate :has_canonical

    def initialize(args)
      @driver = args[:driver]
    end

    def only_one_h1
      h1_tags = @driver.find_elements(:css, 'h1')
      unless h1_tags.length <= 1
        self.errors.add(:seo, "Expeced 1 or less h1 tags not: #{h1_tags.length}")
      end
    end

    def page_title
      title = @driver.title
      unless title.length > 1
        self.errors.add(:seo, "Page title too short")
      end
    end

    def has_canonical
      anchor_links  = @driver.find_elements(:css, "a").select { |x| x.attribute('rel') == "canonical" }.compact
      link_tags     = @driver.find_elements(:css, "link").select { |x| x.attribute('rel') == "canonical" }.compact
      all_links     = anchor_links + link_tags
      all_hrefs     = all_links.collect { |l| l.attribute('href')}.compact
      correct_hrefs = all_hrefs.select do |href|
        href.index(HC_BASE_URL) == 0 || href.index("http://www.healthcentral.com") == 0
      end

      unless all_links.length == 1
        self.errors.add(:seo, "Page had #{all_links.length} canonical links not 1")
      end

      unless all_hrefs.length == 1 
        self.errors.add(:seo, "Founds #{all_hrefs.length} hrefs on #{all_links.length} canonical links")
      end

      unless correct_hrefs.length == 1
        self.errors.add(:seo, "None of the canonical links had a valid href; #{correct_hrefs}")
      end
    end
  end
end