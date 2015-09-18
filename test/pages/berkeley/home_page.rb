require_relative './berkeley_page'

module Berkeley
  class BerkeleyHomePage < BerkeleyPage
    attr_reader :driver, :proxy

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
      @header = args[:header]
      @footer = args[:footer]
    end

    def functionality(args)
      Functionality.new(:driver => @driver)
    end

    def seo
      BerkeleySeo::Seo.new(:driver => @driver)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :no_noindex_tag

    def initialize(args)
      @driver = args[:driver]
    end

    def no_noindex_tag
      no_index = @driver.find_elements(:css, "meta[name='robots']")
      unless no_index.empty?
        self.errors.add(:functionality, "Noindex tag found: #{no_index.first.attribute('content')}")
      end
    end
  end
end