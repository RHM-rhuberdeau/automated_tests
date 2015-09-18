module BerkeleySeo
  class Seo
    include ::ActiveModel::Validations

    validate :canonical_links

    def initialize(args)
      @driver = args[:driver]
    end

    def canonical_links
      anchor_links  = @driver.find_elements(:css, "a").select { |x| x.attribute('rel') == "canonical" }.compact
      link_tags     = @driver.find_elements(:css, "link").select { |x| x.attribute('rel') == "canonical" }.compact
      all_links     = anchor_links + link_tags
      bad_links = all_links.map do |link|
        unless link.attribute('href').index(BW_BASE_URL) == 0
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