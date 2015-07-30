require_relative './../the_body/the_body_page'

module TheBodyKeystoneArticle
  class KeystoneArticlePage < TheBodyPage

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
        text     = element.text if element

        if element && text 
          unless element.displayed? == true
            self.errors.add(:base, "Ask the Experts was not displayed on the page.")
          end
          unless text.strip == "ASK THE EXPERTS"
            self.errors.add(:base, "Ask The Experts missing from the page.Found this instead: #{text}")
          end
        end
        unless element && text 
          self.errors.add(:global_test_cases, "Ask the Experts was not displayed on the page.")
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
        unless section_header.first && section_header.first.displayed? == true
          self.errors.add(:base, "Articles section header was not displayed on the page")
        end
      end

      def connect_with_others
        section_header  = @headers.select {|x| x.text == "CONNECT WITH OTHERS"}

        unless section_header.length == 1
          self.errors.add(:base, "Missing the 'CONNECT WITH OTHERS' section header")
        end 
        unless section_header.first && section_header.first.displayed? == true
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