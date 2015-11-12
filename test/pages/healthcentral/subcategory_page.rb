require_relative './healthcentral_page'

module HealthCentral
  class SubcategoryPage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality
      Functionality.new(:driver => @driver, :proxy => @proxy)
    end

    class Functionality
      include ::ActiveModel::Validations

      validate :title_for_each_latest_post
      validate :hero_post
      validate :we_recommend
      validate :latest_posts
      validate :more_resources
      validate :relative_links_in_right_rail


      def initialize(args)
        @driver = args[:driver]
        @proxy  = args[:proxy]
      end

      def title_for_each_latest_post
        latest_posts = @driver.find_elements(:css, "span.Teaser-title")
        if latest_posts
          latest_post_titles = latest_posts.collect(&:text)
          latest_post_titles = latest_post_titles.map {|p| p.gsub(" ", "") }.map {|p| p.gsub("...", "")}
          latest_post_titles = latest_post_titles.select { |x| x.length > 0}
        end

        unless latest_posts
          self.errors.add(:functionality, "Missing latest posts on the page")
        end
        unless latest_post_titles && latest_post_titles.length == 3
          self.errors.add(:functionality, "One of the latest posts had a blank title")
        end
      end

      def hero_post
        hero_image      = @driver.find_element(:css, "div.HeroBox a img")
        hero_link       = @driver.find_elements(:css, "div.HeroBox a").last
        hero_link_text  = hero_link.text
        unless hero_image
          self.errors.add(:functionality, "Missing hero image")
        end
        unless hero_link
          self.errors.add(:functionality, "No hero image on page")
        end
        unless hero_link_text
          self.errors.add(:functionality, "Missing hero post text")
        end
      end

      def we_recommend
        we_recommend_text = @driver.find_element(:css, "h4").text
        posts             = @driver.find_elements(:css, "ul.CollectionListBoxes-list")
        post_images       = @driver.find_elements(:css, "ul.CollectionListBoxes-list li a img")
        post_links        = @driver.find_elements(:css, "ul.CollectionListBoxes-list li a")

        post_links ? post_titles = post_links.collect(&:text) : post_titles = ''   

        unless post_images.length == 3
          self.errors.add(:Functionality, "We recommend had #{post_images.length} images, not 3")
        end
        unless post_links.length == 3
          self.errors.add(:Functionality, "We recommend had #{post_links.length} links, not 3")
        end
        unless post_titles.length == 3
          self.errors.add(:Functionality, "We recommend had #{post_titles.length} titles, not 3")
        end
      end

      def latest_posts
        2.times do 
          wait_for { @driver.find_element(:css, ".js-CollectionEditorsPicks-view-more").displayed? }
          button = @driver.find_element(:css, ".js-CollectionEditorsPicks-view-more")
          begin
            button.click
          rescue Net::ReadTimeout
          end
          wait_for { !@driver.find_element(:css, ".spinner-container").displayed? }
          sleep 0.5
        end
        editor_picks = @driver.find_elements(:css, ".Editor-picks-item")
        unless editor_picks.length >=5
          self.errors.add(:functionality, "#{editor_picks.length} lastest posts appeared, not 5")
        end
      end

      def more_resources
        text  = @driver.find_element(:css, ".Moreresources h4.Block-title").text
        links = @driver.find_elements(:css, ".Moreresources-container ul li a")

        unless text.downcase == "more resources"
          self.errors.add(:functionality, "More Resources title was #{text} not More Resources")
        end
        unless links.length >= 5
          self.errors.add(:functionality, "#{links.length} appeared in more resources, not 3")
        end
      end

      def relative_links_in_right_rail
        wait_for { @driver.find_element(:css, ".MostPopular-container").displayed? }
        links = ((@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact) - @driver.find_elements(:css, "span.RightrailbuttonpromoItem-title a").collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link 
          end
        end
        unless bad_links.compact.length == 0  
          self.errors.add(:functionality, "There were links in the header that did not use relative paths: #{bad_links.compact}")
        end
      end
    end
  end
end