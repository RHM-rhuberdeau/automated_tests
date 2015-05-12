module HealthCentralFooter
  class RedesignFooter
    include ::ActiveModel::Validations

    validate :footer

    def initialize(args)
      @driver = args[:driver]
    end

    def footer
      footer_links = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "About Us" || x.text == "Contact Us" || x.text == "Privacy Policy" || x.text == "Terms of Use" || x.text == "Security Policy" || x.text == "Advertising Policy" || x.text == "Advertise With Us" }
      other_sites = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "The Body" || x.text == "The Body Pro" || x.text == "Berkeley Wellness" || x.text == "Health Communities" || x.text == "Health After 50" || x.text == "Intelecare" || x.text == "Mood 24/7"}
      unless footer_links.length == 7
        self.errors.add(:base, "Links missing from footer: #{footer_links}")
      end
      unless other_sites.length == 7
        self.errors.add(:base, "Missing links to other sites in the footer: #{other_sites}")
      end
    end
  end
end