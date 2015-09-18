require_relative './healthcentral_page'

module FDB
  class FDBPage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    def initialize(args)
      @driver = args[:driver]
    end
  end
end