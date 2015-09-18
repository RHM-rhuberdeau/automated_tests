require_relative './../the_body/the_body_page'

module TheBodyArticle
  class TheBodyArticlePage < TheBodyPage

    def initialize(args)
      @driver  = args[:driver]
      @proxy   = args[:proxy]
      @fixture = args[:fixture]
      @header  = args[:header]
      @footer  = args[:footer]
    end

    def functionality
      Functionality.new(:driver => @driver)
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :header => @header, :footer => @footer)
    end

    class Functionality
      include ::ActiveModel::Validations

      validate :nav_links
      validate :preheadline
      validate :h1
      validate :subheadline
      validate :byline
      validate :displaydate
      validate :bodytext
      validate :see_also
      validate :latest_videos
      validate :most_viewed

      #right nav
      

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def present_with_text?(node)
        unless node
          self.errors.add(:functionality, "#{node.tag_name}.#{node.attribute 'class'} missing from page")
        end
        if node 
          unless node.text.length > 0
            self.errors.add(:functionality, "#{node.tag_name}.#{node.attribute 'class'} was blank")
          end
        end
      end

      def nav_links
        nav_links = @driver.find_elements(:css, "table.navlinks a")
        unless nav_links
          self.errors.add(:functionality, ".nav_links links did not appear on the page")
        end
        if nav_links 
          links         = nav_links.map {|x| x.attribute('href') }
          unless links.compact.length == nav_links.length
            self.errors.add(:functionality, "Some links were missing from .nav_links")
          end
        end
      end

      def preheadline
        preheadline = find "font.preheadline"
        unless preheadline
          self.errors.add(:functionality, "font.preheadline missing from page")
        end
        if preheadline 
          unless preheadline.text.length > 0
            self.errors.add(:functionality, "font.preheadline was blank")
          end
        end
      end

      def h1
        h1 = find "h1"
        unless h1
          self.errors.add(:functionality, "h1 missing from page")
        end
        if h1 
          unless h1.text.length > 0
            self.errors.add(:functionality, "h1 was blank")
          end
        end
      end

      def subheadline
        subheadline = find "div.subheadline"
        unless subheadline
          self.errors.add(:functionality, "div.subheadline missing from page")
        end
        if subheadline 
          unless subheadline.text.length > 0
            self.errors.add(:functionality, "div.subheadline was blank")
          end
        end
      end

      def byline
        bylines = @driver.find_elements(:css, "span.byline")
        unless bylines
          self.errors.add(:functionality, "span.byline missing from page")
        end
        if bylines
          bylines.each do |byline|
            unless byline.text.length > 0
              self.errors.add(:functionality, "a span.byline was blank")
            end
          end
        end
      end

      def displaydate
        displaydate = find "p.displaydate"
        unless displaydate
          self.errors.add(:functionality, "p.displaydate missing from page")
        end
        if displaydate 
          unless displaydate.text.length > 0
            self.errors.add(:functionality, "p.displaydate was blank")
          end
        end
      end

      def bodytext
        bodytext = find "div.bodytext"
        unless bodytext
          self.errors.add(:functionality, "div.bodytext missing from page")
        end
        if bodytext 
          unless bodytext.text.length > 0
            self.errors.add(:functionality, "div.bodytext was blank")
          end
        end
      end

      def see_also
        begin
          see_also = @driver.find_element(:xpath, '//*[@id="midrightcontent"]/div[1]')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          see_also = nil
        end
        begin
          see_also_img = @driver.find_element(:xpath, '//*[@id="seealso"]/tbody/tr[1]/td/img')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          see_also = nil
        end

        unless see_also
          self.errors.add(:functionality, "See Also module was missing from the page")
        end
        unless see_also_img
          self.errors.add(:functionality, "See Also module was missing an image")
        end
      end

      def latest_videos
        begin
          latest_videos = @driver.find_element(:xpath, '//*[@id="seealso"]')
        rescue Selenium::WebDriver::Error::NoSuchElementError
          latest_videos = nil
        end 
        latest_videos_img = find "#seealso > tbody > tr:nth-child(1) > td > img"

        unless latest_videos
          self.errors.add(:functionality, "Latest videos missing from the page")
        end
        unless latest_videos_img
          self.errors.add(:functionality, "Latest videos image missing from the page")
        end
      end

      def most_viewed
        most_viewed  = find "#midrightcontent > div:nth-child(3)"
        viewed       = find "#topTab1"
        viewed_link  = find "#topTab1 a"
        emailed      = find "#topTab2"
        emailed_link = find "#topTab2 a"
        linked_articles = find "#topListClick .sa_fixedtable a"

        unless most_viewed
          self.errors.add(:functionality, "Most Viewed module is missing from the page")
        end
        unless viewed
          self.errors.add(:functionality, "Viewed tab missing from the Most Viewed module")
        end
        unless viewed_link
          self.errors.add(:functionality, "Viewed link missing from the Most Viewed module")
        end
        unless emailed
          self.errors.add(:functionality, "Emailed tab missing from the Most Viewed module")
        end
        unless emailed_link
          self.errors.add(:functionality, "Emailed link missing from the Most Viewed module")
        end
        unless linked_articles
          self.errors.add(:functionality, "Most Viewed module did not have linked articles in it")
        end
      end
    end

    class GlobalTestCases
      include ::ActiveModel::Validations

      validate :head_navigation
      validate :footer

      def initialize(args)
        @head_navigation = args[:header]
        @footer          = args[:footer]
      end

      def head_navigation
        @head_navigation.validate
        unless @head_navigation.errors.empty?
          self.errors.add(:head_navigation, @head_navigation.errors.values.first)
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
end