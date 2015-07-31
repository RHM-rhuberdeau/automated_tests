module BerkeleyHeader
  class DesktopHeader
    include ::ActiveModel::Validations

    validate :canonical_links

    def initialize(args)
      @driver = args[:driver]
    end

    def canonical_links
      home_link = find "li.icon_home a"
      supplements = find "#mainmenu > ul > li:nth-child(2) > a"

      unless home_link.attribute('rel') == "foo"
        self.errors.add(:header, "Home icon link missing canonical")
      end

      unless supplements.attribute('rel') == "foo"
        self.errors.add(:header, "Supplements link missing canonical")
      end
    end
  end
end