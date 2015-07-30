require_relative './the_body_page'
require_relative './concerns/mobile_ad_test_cases'

module TheBody
  class TheBodyMobilePage < TheBodyPage
    include TheBodyMobileAds

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

    def ads
      TheBodyMobileAds::AdsTestCases.new(:driver => @driver, :proxy => @proxy)
    end

    class Functionality
      include ::ActiveModel::Validations

      def initialize(args)
        @driver = args[:driver]
      end
    end 

    class GlobalTestCases 
      include ::ActiveModel::Validations

      validate :the_body_logo
      validate :resource_centers
      validate :topics_in_header
      validate :the_body_links
      validate :ask_the_experts

      def initialize(args)
        @driver = args[:driver]
        @resource_center_links  = ["African Americans", "Aging", "Gay Men", "Latinos", "Women", "Newly Diagnosed", "Starting Treatment", "Keeping Up With Your HIV Meds"]
        @treatment_center_links = ["Treatment", "HIV Medications", "Hepatitis C Coinfection", "GI Issues", "Other Side Effects & Coinfections", "Drug Resistance", "Switching & Stopping Treatment", "Pediatric HIV Treatment", "Prevention", "HIV/AID Basics", "HIV Prevention", "HIV Testing", "Safer Sex", "Other Sexually Transmitted Diseases", "Myths About HIV/AIDS", "History of the AIDS Epidemic", "Immune System Basics", "Helping Friends With HIV/AIDS", "Living With HIV", "Getting Good Care", "Healthy Living With HIV", "Arts, Media & HIV/AIDS", "Diet, Nutrition & HIV/AIDS", "HIV Stigma", "Relationships, Sexuality & HIV/AIDS", "Vitamins, Minerals & Supplements", "HIV and Financial Issues", "HIV and Legal Issues", "Personal Stories", "HIV Blog Central", "Stories About Men", "Stories About Women", "Stories About Transgender People", "Stories About Young People", "Stories About Older People", "Stories About Families and Loved Ones"]
        @tool_links             = []
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
        resource_center_header  = @driver.find_element(:css, ".Nav--Primary.js-Nav--Primary ul.Nav-list ul.Nav-listGroup-list--Featured li.js-Nav--Primary-accordion-title")
        wait_for { resource_center_header.displayed? }
        resource_center_header.click
        wait_for { @driver.find_element(:link_text, "Keeping Up With Your HIV Meds").displayed? }
        resource_center_links   = @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured a")
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
        treatment_header  = @driver.find_element(:css, ".Nav--Primary.js-Nav--Primary ul.Nav-list ul.Nav-listGroup-list--General  li.js-Nav--Primary-accordion-title")
        wait_for { treatment_header.displayed? }
        treatment_header.click
        wait_for { @driver.find_element(:link_text, "Stories About Families and Loved Ones").displayed? }
        treatment_links   = @driver.find_elements(:css, ".Nav-listGroup-list--General a")
        link_texts        = treatment_links.collect(&:text)
        missing_links     = @treatment_center_links - link_texts
        header_text       = treatment_header.text
        treatment_hrefs   = treatment_links.collect {|x| x.attribute('href')}
        invalid_hrefs     = treatment_hrefs.select {|x| x.length == 0 || x.nil?}

        unless treatment_header.displayed? == true
          self.errors.add(:base, "TOPICS IN HIV/AIDS nav link not displayed")
        end
        unless header_text == "TOPICS IN HIV/AIDS"
          self.errors.add(:base, "TOPICS IN HIV/AIDS was missing from the nav")
        end
        unless missing_links.empty?
          self.errors.add(:base, "Missing the following links under Topics In Hiv/Aids: #{missing_links}")
        end
        unless invalid_hrefs.length == 0
          self.errors.add(:base, "Some links under TOPICS IN HIV/AIDS were missing hrefs.")
        end
      end

      def the_body_links
        the_body_tools_header = @driver.find_element(:css, ".Nav-listGroup-list--HealthTools")
        wait_for { the_body_tools_header.displayed? }
        the_body_tools_header.click
        wait_for { @driver.find_element(:link_text, "ASOFinder.com").displayed? }
        tool_links            = @driver.find_elements(:css, ".Nav-listGroup-list--HealthTools a")
        link_texts            = tool_links.collect(&:text)
        missing_links         = @tool_links - link_texts
        header_text           = the_body_tools_header.text
        the_body_hrefs        = tool_links.collect {|x| x.attribute('href')}
        invalid_hrefs         = the_body_hrefs.select {|x| x.length == 0 || x.nil?}

        unless the_body_tools_header.displayed? == true
          self.errors.add(:base, "THEBODY.COM was not displayed")
        end
        unless header_text == "THEBODY.COM"
          self.errors.add(:base, "THEBODY.COM missing from the nav")
        end
        unless missing_links.empty?
          self.errors.add(:base, "Missing the following links under THEBODY.COM: #{missing_links}")
        end
        unless invalid_hrefs.length == 0
          self.errors.add(:base, "Some links under THEBODY.COM were missing hrefs.")
        end
      end

      def ask_the_experts
        ask_experts_header = @driver.find_element(:css, ".Nav-listGroup-list--Ask-a-question")
        ask_experts_link   = @driver.find_element(:css, ".Nav-listGroup-list--Ask-a-question a")

        unless ask_experts_link.displayed? == true
          self.errors.add(:base, "Ask Expert Link not displayed")
        end
        unless ask_experts_link.text == "ASK THE EXPERTS"
          self.errors.add(:base, "Ask Expert link missing from header.")
        end
        unless ask_experts_link.attribute('href').length > 0
          self.errors.add(:base, "Invalid href on the Ask The Experts link")
        end
      end
    end
  end
end