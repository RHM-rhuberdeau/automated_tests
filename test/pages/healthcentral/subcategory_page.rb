require_relative './healthcentral_page'

module HealthCentral
  class SubcategoryPage < HealthCentralPage
    def initialize(args)
      @driver       = args[:driver]
      @proxy        = args[:proxy]
      @fixture      = args[:fixture]
    end

    def assets
      all_images = @driver.find_elements(tag_name: 'img')
      HealthCentralAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end
  end
end