module HealthCentralSeo
  class Seo
    include ::ActiveModel::Validations
    include Capybara::DSL

    validate :only_one_h1
    validate :page_title
    validate :has_canonical

    def initialize
    end

    def only_one_h1
      h1_tags = all('h1')
      unless h1_tags.length <= 1
        self.errors.add(:seo, "Expeced 1 or less h1 tags not: #{h1_tags.length}")
      end
    end

    def page_title
      page_title = title
      unless page_title.length > 1
        self.errors.add(:seo, "Page title too short")
      end
    end

    def has_canonical
      anchor_links  = all('a[rel="canonical"]', :visible => false)
      links         = all('link[rel="canonical"]', :visible => false)
      all_links     = anchor_links.to_a + links.to_a
      all_hrefs     = all_links.collect { |l| l[:href]}.compact
      correct_hrefs = all_hrefs.select do |href|
        href.index(HC_BASE_URL) == 0 || href.index("http://www.healthcentral.com") == 0
      end

      unless all_links.length == 1
        self.errors.add(:seo, "Page had #{all_links.length} canonical links not 1")
      end

      unless correct_hrefs.length >= 1
        self.errors.add(:seo, "None of the canonical links had a valid href; #{correct_hrefs}")
      end
    end
  end
end