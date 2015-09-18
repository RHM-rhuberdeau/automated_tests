require_relative './healthcentral_page'

module HealthCentralEncyclopedia
  class EncyclopediaPage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
      @fixture          = args[:fixture]
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    def initialize(args)
      @driver = args[:driver]
      @proxy  = args[:proxy]
    end
  end
end
