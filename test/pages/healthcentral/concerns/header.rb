module HealthCentralHeader
  class MobileLBLN
    include ::ActiveModel::Validations

    validate :logo
    validate :title_link
    validate :more_on_link

    def initialize(args)
      @driver       =args[:driver]
      @logo         = args[:logo]
      @title_link   = args[:title_link]
      @more_on_link = args[:more_on_link]
    end

    def logo
      logo = @driver.find_element(:css, ".Logo-supercollection img")
      logo_img = logo.attribute('src') if logo
      unless logo_img == @logo
        self.errors.add(:base, "Logo image src was #{logo_img} not #{@logo}")
      end
    end

    def title_link
      title_link = @driver.find_element(:css, "a.title-supercollection")
      title_text = title_link.text if title_link
      unless title_text == @title_link
        self.errors.add(:base, "Title link was #{title_text} not #{@title_link}")
      end
    end

    def more_on_link
      more_on_link = @driver.find_element(:css, "span.more-supercollection")
      link         = more_on_link.text if more_on_link
      unless link == @more_on_link
        self.errors.add(:base, "More on link was #{link} not #{@more_on_link}")
      end
    end
  end
end