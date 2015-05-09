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
      @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
      omniture = HealthCentralOmniture::Omniture.new(omniture_text, @fixture)
    end
  end
end