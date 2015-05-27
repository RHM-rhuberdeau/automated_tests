require_relative './../the_body/the_body_page'

module TheBodyEVP
  class TheBodyEVPPage < TheBodyPage

    def initialize(args)
      @driver  = args[:driver]
      @proxy   = args[:proxy]
      @fixture = args[:fixture]
    end

    def functionality
      Functionality.new(:driver => @driver)
    end

    def assets
      all_images      = @driver.find_elements(tag_name: 'img')
      Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def omniture
      open_omniture_debugger
      omniture_text = get_omniture_from_debugger
      omniture = TheBodyOmniture::Omniture.new(omniture_text, @fixture)
    end 

    def global_test_cases
      GlobalTestCases.new(:driver => @driver)
    end

    class Functionality
      include ::ActiveModel::Validations

      validate :question_subnav
      validate :bread_crumbs
      validate :question
      validate :answer
      validate :next_previous
      # validate :preheadline
      # validate :h1
      # validate :subheadline
      # validate :byline
      # validate :displaydate
      # validate :bodytext
      # validate :see_also
      # validate :latest_videos
      # validate :most_viewed

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

      def question_subnav
        subnav = find "#maincontent_forums > table"
        recent_answers_link       = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(1)"
        recent_answers_img        = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(1) > img"
        answers_by_category_link  = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(2)"
        answers_by_category_img   = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(2) > img"
        aaq_link                  = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(3)"
        aaq_img                   = find "#maincontent_forums > table > tbody > tr:nth-child(2) > td > a:nth-child(3) > img"

        unless subnav
          self.errors.add(:functionality, "Subnav did not appear on the page")
        end
        unless recent_answers_link
          self.errors.add(:functionality, "Recent answers link did not appear on the page")
        end
        unless recent_answers_img
          self.errors.add(:functionality, "Recent answers image did not appear on the page")
        end
        unless answers_by_category_link
          self.errors.add(:functionality, "Answers by category link did not appear on the page")
        end
        unless answers_by_category_img
          self.errors.add(:functionality, "Answers by category img did not appear on the page")
        end
        unless aaq_link
          self.errors.add(:functionality, "AAQ link did not appear on the page")
        end
        unless aaq_img
          self.errors.add(:functionality, "AAQ img did not appear on the page")
        end
      end

      def bread_crumbs
        link1 = find "#maincontent_forums > div:nth-child(6) > a:nth-child(1)"
        link2 = find "#maincontent_forums > div:nth-child(6) > a:nth-child(2)"
        link3 = find "#maincontent_forums > div:nth-child(6) > a:nth-child(3)"

        unless link1 
          self.errors.add(:functionality, "First breadcrumb link did not appear on the page")
        end
        unless link2 
          self.errors.add(:functionality, "Second breadcrumb link did not appear on the page")
        end
        unless link3 
          self.errors.add(:functionality, "Third breadcrumb link did not appear on the page")
        end
      end

      def question
        question              = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(1) > td:nth-child(3)"
        question_header       = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(1) > td:nth-child(3) > font.qna"
        question_header_text  = question_header.text if question_header
        question_text         = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(1) > td:nth-child(3)"
        question_body         = question_text.text if question_text

        unless question
          self.errors.add(:functionality, "The question did not appear on the page")
        end
        unless question_header
          self.errors.add(:functionality, "The question header did not appear on the page")
        end
        unless question_header_text && question_header_text.length > 0
          self.errors.add(:functionality, "The question header was blank")
        end
        unless question_text
          self.errors.add(:functionality, "The page did not have a full question")
        end
        unless question_body && question_body.length > 0
          self.errors.add(:functionality, "The question was blank")
        end
      end

      def answer
        response              = find "#response"
        response_header       = find "#response .qna"
        response_header_text  = response_header.text if response_header
        response_body         = response.text if response

        unless response
          self.errors.add(:functionality, "The page did not have a response")
        end
        unless response_header
          self.errors.add(:functionality, "The response header was missing")
        end
        unless response_header_text && response_header_text.length > 0
          self.errors.add(:functionality, "The response header was blank")
        end
        unless response_body && response_body.length > 0
          self.errors.add(:functionality, "The page was missing a full response")
        end
      end

      def next_previous
        next_previous_table   = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1)"
        previous_button       = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(1) > a:nth-child(1) > img"
        previous_link         = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(1) > a:nth-child(1)"
        previous_article_link = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(1) > a:nth-child(3)"
        next_button           = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(2) > a:nth-child(1) > img"
        next_link             = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(2) > a:nth-child(1)"
        next_article_link     = find "#maincontent_forums > div:nth-child(8) > table > tbody > tr:nth-child(6) > td > table:nth-child(1) > tbody > tr > td:nth-child(2) > a:nth-child(3)"

        unless next_previous_table
          self.errors.add(:functionality, "The Next/Previous table was missing")
        end
        unless previous_button
          self.errors.add(:functionality, "The Previous button image was missing")
        end
        unless previous_link
          self.errors.add(:functionality, "The link on the Previous button was missing")
        end
        unless previous_article_link
          self.errors.add(:functionality, "The previous article link was missing")
        end
        unless next_button
          self.errors.add(:functionality, "The Next button image was missing")
        end
        unless next_link
          self.errors.add(:functionality, "The link on the Next button was missing")
        end
        unless next_article_link
          self.errors.add(:functionality, "THe link to the next article was missing")
        end
      end
    end
  end
end