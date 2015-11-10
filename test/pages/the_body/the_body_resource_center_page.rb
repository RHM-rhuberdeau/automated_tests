require_relative './../the_body/the_body_page'

module TheBodyArticle
  class TheBodyResourceCenterPage < TheBodyPage

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

      validate :h1
      validate :byline
      validate :displaydate
      validate :bodytext
      # validate :see_also
      # validate :latest_videos
      # validate :most_viewed

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def h1
        h1 = find "div.articletext h1"
        unless h1
          self.errors.add(:functionality, "div.articletext h1 missing from page")
        end
        if h1 
          unless h1.text.length > 0
            self.errors.add(:functionality, "div.articletext h1 was blank")
          end
        end
      end

      def byline
        bylines = @driver.find_elements(:css, "div.articletext span.byline")
        unless bylines
          self.errors.add(:functionality, "div.articletext span.byline missing from page")
        end
        unless bylines.length == 2
          self.errors.add(:functionality, "Expected 2 bylines not #{bylines.length}")
        end
      end

      def displaydate
        displaydate = find "div.articletext p.displaydate"
        unless displaydate
          self.errors.add(:functionality, "div.articletext p.displaydate missing from page")
        end
        if displaydate 
          unless displaydate.text.length > 0
            self.errors.add(:functionality, "div.articletext p.displaydate was blank")
          end
        end
      end

      def bodytext
        bodytext = find "div.articletext div.bodytext"
        unless bodytext
          self.errors.add(:functionality, "div.articletext div.bodytext missing from page")
        end
        if bodytext 
          unless bodytext.text.length > 0
            self.errors.add(:functionality, "div.articletext div.bodytext was blank")
          end
        end
      end

      def see_also 
        see_also = find "#seealso_650"
        unless see_also
          self.errors.add(:functionality, "See Also missing from the page")
        end
        if see_also
          links = see_also.find_elements(:css, "a")
          unless links.length == 3
            self.errors.add(:functionality, "Missing links from the See Also section")
          end
        end
      end
    end

    class GlobalTestCases
      include ::ActiveModel::Validations

      validate :head_navigation
      # validate :footer

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