module BerkeleySeo
  class Seo
    include ::ActiveModel::Validations

    validate :canonical_links

    def initialize(args)
      @driver = args[:driver]
    end

    def canonical_links
      links = @driver.find_elements(:css, "a").select { |x| x.attribute('rel') == "canonical" }.compact
      bad_links = links.map do |link|
        unless link.attribute('href').index(ASSET_HOST) == 0
          link
        end
      end

      unless links.length > 0
        self.errors.add(:seo, "Page was missing canonical link")
      end

      unless bad_links.length == 0 
        self.errors.add(:seo, "Some canonical links had an invalid href #{bad_links}")
      end
    end
  end
end