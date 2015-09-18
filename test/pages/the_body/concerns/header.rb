module TheBodyHeader
  class ArticleHeader
    include ::ActiveModel::Validations

    validate :header_navbar

    def initialize(args)
      @driver = args[:driver]
    end

    def header_navbar
      logo                = find "div.header-table.header-top-row a#header-logo img"
      first_header_cell   = @driver.find_elements(:css, "div.header-table.header-top-row div.header-cell a.bordered")
      if first_header_cell
        first_header_cell = first_header_cell.select {|x| x.displayed?}
      end
      social_buttons = []
      bottom_header_row   = @driver.find_elements(:css, "div.header-table.header-bottom-row a")

      unless logo
        self.errors.add(:header, "Body log was missing from the head nav")
      end
      unless first_header_cell.length == 5
        self.errors.add(:header, "Expected 5 links in the first header cell not #{first_header_cell.length}")
      end
      unless bottom_header_row.length == 6
        self.errors.add(:header, "Expected 6 links in the bottom header row not #{bottom_header_row.length}")
      end
    end
  end
end