require_relative './../the_body/the_body_page'

module TheBodyLBLN
  class TheBodyLBLNPage < TheBodyPage

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