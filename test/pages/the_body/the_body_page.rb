require_relative './../healthcentral/healthcentral_page'

module TheBody
  class TheBodyPage < HealthCentralPage

    def initialize(args)
      @driver  = args[:driver]
      @proxy   = args[:proxy]
      @fixture = args[:fixture]
    end

    def functionality
      Functionality.new(:driver => @driver)
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver)
    end

    def assets
      all_images      = @driver.find_elements(tag_name: 'img')
      Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def omniture
      @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
      omniture = Omniture.new(omniture_text, @fixture)
    end 

    def has_correct_title?
      title = @driver.title
      title.scan(/^[^\-]*-[\s+\w+]+/).length == 1
    end

    class Omniture < HealthCentralPage::Omniture
      def correct_report_suite
        if ENV['TEST_ENV'] != 'production'
          suite = "cmi-choicemediacom-thebody"
        else
          suite = "cmi-choicemediacom-thebody"
        end
        unless @report_suite == suite
          self.errors.add(:base, "Omniture report suite being used is: #{@report_suite} not #{suite}")
        end
      end
    end

    class Assets
      include ::ActiveModel::Validations

      validate :assets_using_correct_host
      validate :no_broken_images
      validate :no_unloaded_assets

      def initialize(args)
        @proxy     = args[:proxy]
        @all_imgs  = args[:imgs]
      end

      def wrong_asset_hosts
        (["http://uat.thebody.", "http://qa.thebody.", "http://qa1.thebody.","http://qa2.thebody.","http://qa3.thebody.", "http://qa4.thebody.", "http://www.thebody.", "http://alpha.thebody.", "http://stage.thebody."] - [Configuration["thebody"]["asset_host"], ASSET_HOST])
      end

      def assets_using_correct_host
        wrong_assets = page_wrong_assets
        unless wrong_assets.empty?
          self.errors.add(:base, "there were assets loaded from the wrong environment #{wrong_assets}")
        end
      end

      def page_wrong_assets
        site_urls = @proxy.har.entries.map do |entry|
          if entry.request.url.include?("thebody")
            entry.request.url
          end
        end

        site_urls = site_urls.compact

        wrong_assets_on_page = site_urls.map do |site_url|
          if url_has_wrong_asset_host(site_url)
            site_url
          end
        end

        wrong_assets_on_page.compact
      end

      def url_has_wrong_asset_host(url)
        bad_host = wrong_asset_hosts.map do |host_url|
          if url.index(host_url) == 0
            true
          end
        end
        bad_host.compact.length > 0
      end

      def no_unloaded_assets
        unloaded_assets = page_unloaded_assets.compact
        if unloaded_assets.empty? == false
          self.errors.add(:base, "there were unloaded assets #{unloaded_assets}")
        end
      end

      def page_unloaded_assets
        @unloaded_assets ||= @proxy.har.entries.map do |entry|
           if (entry.request.url.split('.com').first.include?("#{HC_BASE_URL}") || entry.request.url.split('.com').first.include?("#{HC_DRUPAL_URL}") ) && entry.response.status != 200
             entry.request.url
          end
        end
        @unloaded_assets.compact
      end

      def right_assets
        right_assets = @proxy.har.entries.map do |entry|
          if entry.request.url.include?(ASSET_HOST)
            entry.request.url
          end
        end
        right_assets.compact
      end

      def no_broken_images
        broken_images = []
        @all_imgs.each do |img|
          broken_images << @proxy.har.entries.find do |entry|
            entry.request.url == img.attribute('src') && entry.response.status == 404
          end
        end
        broken_images = broken_images.compact.collect do |x| 
          x.request.url if (!x.request.url.include?("avatars") && (ENV['TEST_ENV'] != "production")) 
        end
        unless broken_images.compact.empty?
          self.errors.add(:base, "broken images on the page #{broken_images}")
        end
      end
    end#Assets

    class Functionality
      include ::ActiveModel::Validations

      validate :ask_the_experts
      validate :continued_links
      validate :articles_section
      validate :connect_with_others
      validate :related_topics

      def initialize(args)
        @driver  = args[:driver]
        @headers = @driver.find_elements(:css, ".wsModHead")
      end

      def ask_the_experts
        elements = @driver.find_elements(:css, "div.wsModHead")
        element  = elements.first
        text     = element.text

        unless element.displayed? == true
          self.errors.add(:base, "Ask the Experts was not displayed on the page.")
        end
        unless text.strip == "ASK THE EXPERTS"
          self.errors.add(:base, "Ask The Experts missing from the page.Found this instead: #{text}")
        end
      end

      def continued_links
        links               = @driver.find_elements(:css, ".wsEntrySectQ a")
        hrefs               = links.collect {|link| link.attribute('href')}
        link_texts          = links.collect {|link| link.attribute('text')}
        invalid_hrefs       = hrefs.select {|href| href.length == 0 }
        invalid_link_texts  = link_texts.select {|text| text.length == 0}
        undisplayed_links   = links.select { |link| link.displayed? == false }

        unless hrefs.compact.length > 0
          self.errors.add(:base, "Missing continued links")
        end
        unless link_texts.compact.length == hrefs.length
          self.errors.add(:base, "One of the continued links did not have link text.")
        end
        unless invalid_hrefs.compact.length == 0
          self.errors.add(:base, "One of the continued links had an invalid href.")
        end
        unless invalid_link_texts.compact.length == 0
          self.errors.add(:base, "One of the continued links was missing link text.")
        end
        unless undisplayed_links.length == 0 
          self.errors.add(:base, "Some of the continue links were not displayed on the page")
        end
      end

      def articles_section
        section_header  = @headers.select {|x| x.text == "ARTICLES"}
        article_images  = @driver.find_elements(:css, ".wsEntryImage")
        article_images  = article_images.drop(1) #first one is not in the articles section
        article_links   = @driver.find_elements(:css, ".wsEntryAlign h4 a")
        read_mores      = @driver.find_elements(:css, ".wsEntryAlign a ")
        read_mores      = read_mores.select { |link| link.text == "Read more »"}

        unless section_header.length == 1
          self.errors.add(:base, "Missing the 'ARTICLES' section header")
        end
        unless article_images.length >= 4
          self.errors.add(:base, "There were not at least 4 articles in the article section")
        end
        unless article_links.length >= 4
          self.errors.add(:base, "There were not at least 4 article links in the article section")
        end
        unless read_mores.length == article_links.length
          self.errors.add(:base, "One of the articles in the articles section was missing the Read More link: #{read_mores.inspect}")
        end
        unless section_header.first.displayed? == true
          self.errors.add(:base, "Articles section header was not displayed on the page")
        end
      end

      def connect_with_others
        section_header  = @headers.select {|x| x.text == "CONNECT WITH OTHERS"}

        unless section_header.length == 1
          self.errors.add(:base, "Missing the 'CONNECT WITH OTHERS' section header")
        end 
        unless section_header.first.displayed? == true
          self.errors.add(:base, "Connect with others section header was not displayed on the page.")
        end
      end

      def related_topics
        section_header      = @headers.select {|x| x.text == "RELATED TOPICS"}
        related_links       = @driver.find_elements(:css, "ul.wsSideBoxList li a")
        links_without_text  = related_links.select { |link| link.text.nil? || link.text == '' || link.text.length == 0}
        links_without_href  = related_links.select { |link| link.attribute('href').nil? || link.attribute('href').length == 0 || link.attribute('href').length == 0}

        unless section_header.length == 1
          self.errors.add(:base, "Missing the 'RELATED TOPICS' section header")
        end 
        unless related_links.length >= 5
          self.errors.add(:base, "There were less than 5 related topics links")
        end
        unless links_without_href.length == 0
          self.errors.add(:base, "There was a related link without text")
        end
        unless links_without_href.length == 0
          self.errors.add(:base, "There were links with an invalid href")
        end
      end
    end#Functionality

    class GlobalTestCases
      include ::ActiveModel::Validations

      validate :the_body_logo
      validate :resource_centers
      validate :topics_in_header
      validate :treatment_links

      def initialize(args)
        @driver = args[:driver]
        @resource_center_links = ["African Americans", "Aging", "Gay Men", "Latinos", "Women", "Newly Diagnosed", "Starting Treatment", "Keeping Up With Your HIV Meds"]
      end

      def the_body_logo
        logo_image     = @driver.find_element(:css, "span.HC-header-logo a img")
        logo_image_src = logo_image.attribute('src')
        logo_image_link = @driver.find_element(:css, "span.HC-header-logo a")
        logo_image_link = logo_image_link.attribute('href')

        unless logo_image.displayed? == true
          self.errors.add(:base, "Logo was not displayed")
        end
        unless logo_image_src == "http://www.thebody.com/LBLN/living-with-hiv/img/thebody-logo.png"
          self.errors.add(:base, "Logo image src was wrong. It was #{logo_image_src.inspect}")
        end
        unless logo_image_link == "http://www.thebody.com/"
          self.errors.add(:base, "Logo image linked to the wrong page. It linked to #{logo_image_link.inspect}")
        end
      end

      def resource_centers
        resource_center_header  = @driver.find_element(:css, "ul.Nav-listGroup-list--Featured li.js-Nav--Primary-accordion-title.Nav-listGroup-list-title")
        resource_center_links   = @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured li.js-Nav--Primary-accordion-panel.Nav-listGroupSub ul.Nav-listGroupSub-list li a")
        link_texts              = resource_center_links.collect(&:text)
        missing_links           = @resource_center_links - link_texts
        resource_center_hrefs   = resource_center_links.collect {|x| x.attribute('href')}
        invalid_hrefs           = resource_center_hrefs.select {|x| x.length == 0 || x.nil?}

        unless resource_center_header.displayed? == true
          self.errors.add(:base, "Resource Centers link not displayed")
        end
        unless resource_center_header.text == "RESOURCE CENTERS"
          self.errors.add(:base, "Resource Centers was missing from the Topic in HIV/AIDS nav")
        end
        unless missing_links.length == 0
          self.errors.add(:base, "Missing some links in the resource center. Missing #{missing_links}")
        end
        unless invalid_hrefs.length == 0
          self.errors.add(:base, "Some links in the Resource Center were missing hrefs.")
        end
      end

      def topics_in_header
        header = @driver.find_element(:css, ".Nav-listGroup-list--General li.Nav-listGroup-list-title")
        header_text = header.text

        unless header_text == "TOPICS IN HIV/AIDS"
          self.errors.add(:base, "TOPICS IN HIV/AIDS was missing from the nav")
        end
      end

      def treatment_links

      end
    end
  end
end