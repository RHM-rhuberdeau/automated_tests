require_relative './../the_body/the_body_page'

module TheBodyArticle
  class TheBodyProArchivedPage < TheBodyPage

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
      validate :tools_pad
      

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def h1
        h1 = find ".content_pad h1"
        unless h1
          self.errors.add(:functionality, ".content_pad h1 missing from page")
        end
        if h1 
          unless h1.text.length > 0
            self.errors.add(:functionality, ".content_pad h1 was blank")
          end
        end
      end

      def byline
        byline = find ".content_pad p.byline"
        unless byline
          self.errors.add(:functionality, ".content_pad p.byline missing from page")
        end
        if byline
          unless byline.text.length > 0
            self.errors.add(:functionality, ".content_pad p.byline was blank")
          end
        end
      end

      def displaydate
        displaydate = find ".content_pad p.displaydate"
        unless displaydate
          self.errors.add(:functionality, ".content_pad p.displaydate missing from page")
        end
        if displaydate 
          unless displaydate.text.length > 0
            self.errors.add(:functionality, ".content_pad p.displaydate was blank")
          end
        end
      end

      def bodytext
        bodytext = find ".content_pad div.bodytext"
        unless bodytext
          self.errors.add(:functionality, ".content_pad div.bodytext missing from page")
        end
        if bodytext 
          unless bodytext.text.length > 0
            self.errors.add(:functionality, ".content_pad div.bodytext was blank")
          end
        end
      end

      def tools_pad 
        nodes = @driver.find_elements(:css, "div#newmainright div.tools_pad div")
        unless nodes.length >= 2
          self.errors.add(:functionality, "Tools pad was missing from the right rail")
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