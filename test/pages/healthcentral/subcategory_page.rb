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

    def omniture
      open_omniture_debugger
      omniture_text = get_omniture_from_debugger
      omniture = HealthCentralOmniture::Omniture.new(omniture_text, @fixture)
    end
  end
end