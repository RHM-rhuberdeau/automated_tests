require_relative './healthcentral_page'

module Immersives
  class ImmersivePage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @header           = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      Functionality.new(:driver => @driver)
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :header => @header, :footer => @footer)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

  end

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :head_navigation
    validate :footer

    def initialize(args)
      @header = args[:header]
      @footer = args[:footer]
    end

    def head_navigation
      @header.validate
      unless @header.errors.empty?
        self.errors.add(:head_navigation, @header.errors.values.first)
      end
    end

    def footer
      @footer.validate
      unless @footer.errors.empty?
        self.errors.add(:footer, @footer.errors.values.first)
      end
    end
  end
end