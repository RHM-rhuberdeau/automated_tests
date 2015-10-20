module TheBodyFooter
  class RedesignFooter
    include ::ActiveModel::Validations

    validate :footer_links
    
    def initialize(args)
      @driver = args[:driver]
    end

    def footer_links
      links = @driver.find_elements(:css, ".HC-external-links a")
      unless links.length == 10
        self.errors.add(:footer, "Missing links from the footer")
      end
    end
  end

  class RedesignMobileFooter
    include ::ActiveModel::Validations

    validate :footer_links
    
    def initialize(args)
      @driver = args[:driver]
    end

    def footer_links
      links = @driver.find_elements(:css, ".HC-external-links a")
      unless links.length == 10
        self.errors.add(:footer, "Missing links from the footer")
      end
    end
  end
end