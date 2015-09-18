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
      bad_links = all_links.map do |link|
        unless link.attribute('href').index(HC_BASE_URL) == 0 || link.attribute('href').index("http://www.healthcentral.com") == 0
          link.attribute('href')
        end
      end
      bad_links = bad_links.compact

      unless all_links.length > 0
        self.errors.add(:seo, "Page was missing canonical link")
      end

      unless bad_links.length == 0 
        self.errors.add(:seo, "Some canonical links had an invalid href #{bad_links}")
      end
    end
  end
end