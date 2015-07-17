class BerkeleyFooter
  class DesktopFooter
    include ::ActiveModel::Validations

    validate :customer_service_link
    def initialize(args)
      @driver = args[:driver]
    end

    def customer_service_link
      links = @driver.find_elements(:css, "footer a")  
      link  = links.select { |link| link.text == "CUSTOMER SERVICE"}
      unless link.compact.length == 1
        self.errors.add(:footer, "Missing customer service link in the footer")
      end
    end
  end
end