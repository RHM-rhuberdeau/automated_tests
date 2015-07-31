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

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end
    end
  end
end