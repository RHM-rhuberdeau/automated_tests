require_relative './../the_body/the_body_page'

module TheBodyArticle
  class RedesignArticlePage < TheBodyPage

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

    class Functionality
      include ::ActiveModel::Validations

      validate :page_header
      validate :article_title
      validate :byline
      validate :share_tools
      validate :most_viewed
      validate :comments
      validate :whats_new
      validate :daisy_chain

      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def present_with_text?(css)
        node = find css
        unless node
          self.errors.add(:functionality, "#{css} missing from page")
        end
        if node 
          unless node.text.length > 0
            self.errors.add(:functionality, "#{css} was blank")
          end
        end
      end

      def page_header
        header = find ".Page-category.Page-sub-category.js-page-category"
        unless header
          self.errors.add(:functionality, "Missing page header")
        end
      end

      def article_title
        present_with_text?("h2.Page-info-title")
      end

      def byline
        present_with_text?("div.page-byline")
      end

      def share_tools
        share_links = @driver.find_elements(:css, ".left-social-bar .social-row")
        unless share_links.length == 4
          self.errors.add(:functionality, "Missing some of the share tools")
        end
      end

      def most_viewed
        present_with_text?(".Node-content-secondary .highlight-list h2")
        article_links = @driver.find_elements(:css, ".Node-content-secondary ul li a")
        article_links = article_links.select {|x| x.displayed? }.compact
        unless article_links.length > 0
          self.errors.add(:functionality, "Most Viewed was missing links")
        end
      end

      def comments 
        scroll_to_bottom_of_page
        wait_for { @driver.find_element(:css, "#show-comments-button").displayed? }
        comment_button = find "#show-comments-button"
        comments       = @driver.find_elements(:css, ".comment")
        if comments 
          comments     = comments.select {|c| c.displayed? }
        else
          comments     = []
        end

        unless comments.empty?
          self.errors.add(:functionality, "Comments appeared on the page before the comments button was clicked")
        end

        if comment_button
          comment_button.click 
          wait_for { @driver.find_element(:css, ".comment").displayed? }

          comments = @driver.find_elements(:css, ".comment")
          if comments 
            comments = comments.select {|c| c.displayed? }
          else
            comments = []
          end

          unless comments.length.between?(1,10)
            self.errors.add(:functionality, "Clicking the comment button did not display the comments")
          end
        end
      end

      def whats_new
        title         = find "h2.whats-new-title"
        promo_module  = find "div.whats-new-table"
        promo_links   = @driver.find_elements(:css, ".whats-new-table a")

        if title
          unless title.text == "What's New"
            self.errors.add(:functionality, "Missing what's new title")
          end
        else
          self.errors.add(:functionality, "Missing What's New title on the page")
        end

        unless promo_module
          self.errors.add(:functionality, "Missing What's New section")
        end
        unless promo_links.length == 3
          self.errors.add(:functionality, "Expected 3 What's New links but there were #{promo_links.length}")
        end
      end

      def daisy_chain
        next_article = find ".Page-next-table"
        next_link    = find ".Page-next-table a"
        if next_article
          unless next_article.text.length > 0
            self.errors.add(:functionality, "Missing article title in daisy chain pagination")
          end
          unless next_link
            self.errors.add(:functionality, "Missing the next button")
          end
          current_url = @driver.current_url
          begin
            next_link.click if next_link
          rescue Net::ReadTimeout
            @driver.execute_script("window.stop();")
          end
          new_url = @driver.current_url
          unless current_url != new_url
            self.errors.add(:functionality, "Next link did not load a new article")
          end
        else
          self.errors.add(:functionality, "Mising next article section")
        end
      end
    end
  end
end