require_relative './berkeley_page'

module Articles
  class ArticlePage < BerkeleyPage

    def initialize(args)
      @driver  = args[:driver]
      @proxy   = args[:proxy]
      @fixture = args[:fixture]
    end

    def functionality
      Functionality.new(:driver => @driver)
    end

    class Functionality
      include ::ActiveModel::Validations

      validate :no_noindex_tag

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def no_noindex_tag
        no_index = @driver.find_elements(:css, "meta[name='robots']")
        unless no_index.empty?
          self.errors.add(:functionality, "Noindex tag found: #{no_index.first.attribute('content')}")
        end
      end
    end
  end
end