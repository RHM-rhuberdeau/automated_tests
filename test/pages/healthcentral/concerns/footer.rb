module HealthCentralFooter
  class RedesignFooter
    include ::ActiveModel::Validations

    validate :footer

    def initialize(args)
      @driver = args[:driver]
    end

    def footer
      footer_links    = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "About Us" || x.text == "Contact Us" || x.text == "Privacy Policy" || x.text == "Terms of Use" || x.text == "Security Policy" || x.text == "Advertising Policy" || x.text == "Advertise With Us" }
      other_sites     = @driver.find_elements(:css, "#footer a.HC-link-row-link")
      expected_sites  = ["The Body", "The Body Pro", "Berkeley Wellness", "Health Communities", "Health After 50", "Intelecare", "Mood 24/7"]
      sites_in_footer = other_sites.collect {|x| x.text} if other_sites
      unless footer_links.length == 7
        self.errors.add(:base, "Links missing from footer: #{footer_links}")
      end
      unless ((expected_sites - sites_in_footer ).empty? == true)
        self.errors.add(:base, "Missing links to other sites in the footer: #{expected_sites - sites_in_footer}")
      end
    end
  end
end