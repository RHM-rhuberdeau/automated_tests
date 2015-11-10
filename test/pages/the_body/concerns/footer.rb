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

  class TheBodyPro
    include ::ActiveModel::Validations

    validate :footer_links
    validate :disclaimer

    def initialize(args)
      @driver = args[:driver]
    end

    def footer_links
      links = @driver.find_elements(:css, "div#footer a")
      unless links
        self.errors.add(:footer, "No links in the footer")
      end
      if links
        unless links.length == 9
          self.errors.add(:footer, "Expected 9 links in the footer, no #{links.length}")
        end
      end
    end

    def disclaimer
      disclaimer = find "div#footer p.disclaimer"
      unless disclaimer
        self.errors.add(:footer, "Missing disclaimer from the footer")
      end
      if disclaimer
        unless disclaimer.text.length > 0
          self.errors.add(:footer, "Disclaimer did not have any text")
        end
      end
    end
  end

  class TheBodyProArchived
    include ::ActiveModel::Validations

    validate :footer_links
    validate :disclaimer

    def initialize(args)
      @driver = args[:driver]
    end

    def footer_links
      links = @driver.find_elements(:css, "div#footer a")
      unless links
        self.errors.add(:footer, "No links in the footer")
      end
      if links
        unless links.length == 9
          self.errors.add(:footer, "Expected 9 links in the footer, no #{links.length}")
        end
      end
    end

    def disclaimer
      disclaimer = find "div#footer p.disclaimer"
      unless disclaimer
        self.errors.add(:footer, "Missing disclaimer from the footer")
      end
      if disclaimer
        unless disclaimer.text.length > 0
          self.errors.add(:footer, "Disclaimer did not have any text")
        end
      end
    end
  end
end