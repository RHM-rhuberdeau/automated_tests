module HealthCentralHeader
  class DesktopHeader
    include ::ActiveModel::Validations

    validate :health_logo
    validate :health_az_menu
    validate :social_icons
    validate :social_icons_in_header
    validate :subcategory_navigation

    def health_logo
      logo_1 = @driver.find_element(:css, "span.LogoHC-part1")
      logo_2 = @driver.find_element(:css, "span.LogoHC-part2")

      unless (logo_1.text == "Health" && logo_2.text == "Central")
        self.errors.add(:header, "Health Logo was missing from the page")
      end

      link = @driver.find_element(:css, "a.LogoHC")
      begin
        link.click
      rescue Net::ReadTimeout
      end
      wait_for_page_to_load
      unless @driver.current_url == "#{HC_BASE_URL}/"
        self.errors.add(:header, "The logo linked to #{@driver.current_url} not #{HC_BASE_URL}/")
      end
      @driver.navigate.back
    end

    def health_az_menu
      #Open Health A-Z Menu
      wait_for { @driver.find_element(:css, ".Button--AZ").displayed? }
      nav_on_pageload = @driver.find_elements(:css, ".HC-nav")
      if nav_on_pageload
        nav_on_pageload = nav_on_pageload.select { |x| x.displayed? }
      end

      button = @driver.find_element(:css, ".Button--AZ")
      begin
        button.click
      rescue Net::ReadTimeout

      end
      wait_for { @driver.find_element(:css, ".HC-nav").displayed? }
      wait_for_page_to_load
      az_nav = @driver.find_element(:css, ".HC-nav")

      unless nav_on_pageload.empty?
        self.errors.add(:header, "A-Z was on the page before clicking it")
      end
      unless az_nav
        self.errors.add(:header, "A-Z nav did not appear on the page afer clicking the Health A-Z button")
      end

      #Check for Category Links
      wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
      titles = @driver.find_elements(:css, ".js-Nav--Primary-accordion-title").select {|x| x.displayed? }.select {|x| x.text == "BODY & MIND" || x.text == "FAMILY HEALTH" || x.text == "HEALTHY LIVING"}
      unless titles.length == 3
        self.errors.add(:header, "Not all super categories were on the page. Present were: #{titles}")
      end 

      #Check for Sub Category links
      sub_category_links      = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary .Nav-listGroup-list--General  a")
      sub_category_links_text = sub_category_links.collect {|x| x.text }
      all_links_counted_for   = ::HealthCentralPage::SUB_CATEGORIES - sub_category_links_text
      extra_links             = sub_category_links_text - ::HealthCentralPage::SUB_CATEGORIES

      unless (sub_category_links.length == ::HealthCentralPage::SUB_CATEGORIES.length && all_links_counted_for.empty?)
        self.errors.add(:header, "There were missing or extra subcategory links in the health a-z menu: #{all_links_counted_for}")
      end
      unless (extra_links.empty?)
        self.errors.add(:header, "There were extra sub_category links on the page: #{extra_links}")
      end

      # Commenting out because things are loading slow right now
      # unless ENV['TEST_ENV'] == "stage"
      #   wait_for { @driver.find_element(:css, ".Nav--Primary.js-Nav--Primary a").displayed? }
      #   ibd = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary a").select { |x| x.text == "Digestive Health"}.first
      #   ibd.click
      #   wait_for { @driver.find_element(:css, ".Phases-navigation").displayed? }
      #   unless (@driver.current_url == "#{HC_BASE_URL}/ibd/" || @driver.current_url == "#{HC_BASE_URL}/ibd")
      #     self.errors.add(:header, "IBD linked to #{@driver.current_url} not #{HC_BASE_URL}/ibd/")
      #   end
      #   @driver.navigate.back
      # end
    end

    def social_icons
      wait_for_page_to_load
      wait_for { @driver.find_element(:css, ".HC-header-content span.icon-facebook").displayed? }
      #Check Facebook icon
      fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-facebook")
      fb_icon.click
      sleep 1
      first_window  = @driver.window_handles.first
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://www.facebook.com/HealthCentral" || @driver.current_url == "https://www.facebook.com/HealthCentral?v=app_369284823108595" || @driver.current_url == "https://www.facebook.com/HealthCentral/"
        self.errors.add(:header, "Facebook icon linked to #{@driver.current_url} not https://www.facebook.com/HealthCentral")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Twitter icon
      twitter_icon = @driver.find_element(:css, ".HC-header-content span.icon-twitter")
      twitter_icon.click
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://twitter.com/#!/healthcentral" || @driver.current_url == "https://twitter.com/healthcentral"
        self.errors.add(:header, "Twitter icon linked to #{@driver.current_url} not https://twitter.com/#!/healthcentral")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Pinterest icon
      pinterest_icon = @driver.find_element(:css, ".HC-header-content span.icon-pinterest")
      pinterest_icon.click
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://www.pinterest.com/HealthCentral/"
        self.errors.add(:header, "Pinterest icon linked to #{@driver.current_url} not https://www.pinterest.com/HealthCentral/")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Mail Icon
      mail_icon = @driver.find_element(:css, ".HC-header-content span.icon-mail")
      begin
        mail_icon.click
      rescue Net::ReadTimeout
      end
      wait_for_page_to_load
      
      unless @driver.current_url == "#{HC_BASE_URL}/profiles/c/newsletters/subscribe"
        self.errors.add(:header, "Mail icon linked to  #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
      end
      begin
        menu = @driver.find_element(:css, "div.Subscriptions-main")
      rescue
        menu = nil 
      end
      if menu.nil?
        self.errors.add(:header, "Newsletter page did not load: #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
      end
      @driver.navigate.back
    end

    def social_icons_in_header
      wait_for          { @driver.find_element(:css, "ul.SocialButtons-list").displayed? }
      fb_share          = find "div.HC-header-socialButtons a.js-Social--Follow-actionable-facebook"
      twitter_share     = find "div.HC-header-socialButtons a.js-Social--Follow-actionable-twitter"
      stumbleupon_share = find "div.HC-header-socialButtons a.js-Social--Follow-actionable-pinterest"
      mail_share        = find "div.HC-header-socialButtons a.js-Social--Follow-actionable-newsletters"

      unless fb_share
        self.errors.add(:header, "Missing facebook share from the header")
      end
      unless twitter_share
        self.errors.add(:header, "Missing twitter share from the header")
      end
      unless stumbleupon_share
        self.errors.add(:header, "Missing stumble upon share from the header")
      end
      unless mail_share
        self.errors.add(:header, "Missing mail share from the header")
      end
    end

    def subcategory_navigation
      subcategory       = find "a.Page-category-titleLink"
      related_elements  = @driver.find_elements(:css, "ul.Page-category-related-list a")
      related_links     = related_elements ? related_elements.collect {|x| x.text.strip } : []

      unless @collection == true
        unless subcategory
          self.errors.add(:header, "#{@subcategory} did not appear in the header")
        end
        unless related_elements
          self.errors.add(:header, "#{@related} did not appear in the header")
        end
        if subcategory
          unless subcategory.text == @subcategory
            self.errors.add(:header, "#{@subcategory} did not appear in the header")
          end
        end
        # if related_links
        #   unless related_links.collect {|x| x.text } == @related
        #     self.errors.add(:header, "#{@related} did not appear in the header")
        #   end
        # end
        @related.each do |link|
          unless related_links.include?(link)
            self.errors.add(:header, "Missing related #{link} in header")
          end
        end
      end

      if @collection == true
        if subcategory
          self.errors.add(:header, "#{@subcategory} appeared in the header on a collection page")
        end
        if related_links
          self.errors.add(:header, "#{@related} appeared in the header on a collection page")
        end
      end
    end
  end

  class ImmersiveFlatHeader < DesktopHeader
    validate :title_link

    def initialize(args)
      @driver       = args[:driver]
      @title        = args[:title]
      @subcategory  = args[:sub_category]
    end

    def health_logo
      logo = find ".Logo-supercollection img"
      logo_img = logo.attribute('src') if logo
      unless logo_img == @logo
        self.errors.add(:header, "Logo image src was #{logo_img} not #{@logo}")
      end
    end

    def subcategory_navigation
      subcategory   = find "a.Page-category-titleLink"
      related_links = find "ul.Page-category-related-list a"

      if subcategory
        self.errors.add(:header, "#{@subcategory} appeared in the header on a collection page")
      end
      if related_links
        self.errors.add(:header, "#{@related} appeared in the header on a collection page")
      end
    end

    def title_link
      title = find "div.storyTitle a"
      title_text = title.text if title
      unless title_text == @title 
        self.errors.add(:header, "Missing #{@title} in the header")
      end
    end
  end

  class RedesignHeader < DesktopHeader
    def initialize(args)
      @driver       = args[:driver]
      @logo         = args[:logo]
      @subcategory  = args[:sub_category]
      @related      = args[:related]
    end
  end

  class ClinicalTrialHeader < DesktopHeader
    validate :clinical_trial_text

    def initialize(args)
      @driver  =args[:driver]
      @logo    = "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png"
    end

    def clinical_trial_text
      span = find ".Title-supercollection-ct span"
      span_text = span.text if span
      unless span_text == "Clinical Trials"
        self.errors.add(:head_navigation, "Missing 'Clinical Trials' in the header")
      end
    end

    def subcategory_navigation

    end
  end

  class CustomProgramHeader
    include ::ActiveModel::Validations

    validate :subject_present

    def initialize(args)
      @driver  = args[:driver]
      @subject = args[:subject]
    end

    def subject_present
      title = find "a.title-supercollection"

      unless title
        self.errors.add(:header, "Missing #{@subject} in the header")
      end

      if title
        unless title.text == @subject
          self.errors.add(:header, "Expected #{@subject} in the header not #{title.text}")
        end
      end
    end
  end

  class EncyclopediaDesktop < DesktopHeader
    def initialize(args)
      @driver = args[:driver]
    end

    def subcategory_navigation

    end
  end

  class DailyDoseDesktop < DesktopHeader
    validate :week_is_displayed

    def initialize(args)
      @driver = args[:driver]
    end

    def week_is_displayed

    end

    def subcategory_navigation

    end
  end

  class LBLNDesktop < DesktopHeader
    include ::ActiveModel::Validations

    validate :logo
    validate :title_link
    validate :more_on_link

    def initialize(args)
      @driver       =args[:driver]
      @logo         = args[:logo]
      @title_link   = args[:title_link]
      @more_on_link = args[:more_on_link]
      @subcategory  = args[:sub_category]
      @related      = args[:related]
    end

    def logo
      logo = find ".Logo-supercollection img"
      logo_img = logo.attribute('src') if logo
      unless logo_img == @logo
        self.errors.add(:header, "Logo image src was #{logo_img} not #{@logo}")
      end
    end

    def title_link
      title_link = find "a.title-supercollection"
      title_text = title_link.text if title_link
      unless title_text == @title_link
        self.errors.add(:header, "Title link was #{title_text} not #{@title_link}")
      end
    end

    def more_on_link
      more_on_link = find "span.more-supercollection"
      link         = more_on_link.text if more_on_link
      unless link == @more_on_link
        self.errors.add(:header, "More on link was #{link} not #{@more_on_link}")
      end
    end

    def subcategory_navigation
      subcat_link = find "a.Page-category-titleLink.js-Page-category-titleLink"
      related_links = @driver.find_elements(:css, "ul.Page-category-related-list a")

      if subcat_link
        self.errors.add(:header, "Subcategory link appeared in a LBLN header")
      end

      unless related_links.empty?
        self.errors.add(:header, "Related links appeared in a LBLN header")
      end
    end
  end

  class SPDesktop <DesktopHeader
    include ::ActiveModel::Validations

    validate :title_link
    validate :subcategory_navigation

    def initialize(args)
      @driver       = args[:driver]
      @title_link   = args[:title_link]
      @related      = args[:related]
      @subcategory  = args[:subcategory]
    end

    def title_link
      title_link = find "a.title-supercollection"
      title_text = title_link.text if title_link
      unless title_text == @title_link
        self.errors.add(:header, "Title link was #{title_text} not #{@title_link}")
      end
    end

    def subcategory_navigation
      subcategory   = find "a.Page-category-titleLink.js-Page-category-titleLink"
      related_links = @driver.find_elements(:css, "ul.Page-category-related-list a")

      if subcategory
        self.errors.add(:header, "Subcategory link appeared in the Sponsored Collection header")
      end
      unless related_links
        self.errors.add(:header, "#{@related} did not appear in the header")
      end
      if related_links
        unless related_links.collect {|x| x.text } == @related
          self.errors.add(:header, "#{@related} did not appear in the header")
        end
      end
    end 
  end

  class MobileHeader
    include ::ActiveModel::Validations

    validate :hamburger_menu
    validate :resources_submenu
    validate :body_and_mind_submenu
    validate :family_health

    def hamburger_menu
      #Is the hamburger menu on the page?
      wait_for {@driver.find_element(:css, "i.icon-menu.js-icon-menu").displayed? }
      hamburger_menu = find "i.icon-menu.js-icon-menu"
      unless hamburger_menu
        self.errors.add(:header, "hamburger menu did not appear in the header")
      end

      #It appears on the page but does it have the right submenus and links?
      if hamburger_menu
        hamburger_menu.click 
        sleep 2

        resources = find "ul.Nav-listGroup-list--HealthTools"
        unless resources
          self.errors.add(:header, "Resources submenu did not appear in the header")
        end

        aaq = find "ul.Nav-listGroup-list--Ask-a-question"
        unless aaq 
          self.errors.add(:header, "Ask A Question did not appear in the header")
        end

        body_and_mind = find "ul.Nav-listGroup-list--General "
        unless body_and_mind
          self.errors.add(:header, "Body & Mind submenu did not appear in the header")
        end

        family_health = find "ul.Nav-listGroup-list--Featured"
        unless family_health
          self.errors.add(:header, "Family Health did not appear in the header")
        end

        healthy_living = find "ul.Nav-listGroup-list--Featured"
        unless healthy_living
          self.errors.add(:header, "Healthy Living does not appear in the header")
        end
      end
    end

    def resources_submenu
      resources = find "ul.Nav-listGroup-list--HealthTools li.js-Nav--Primary-accordion-title"
      if resources
        resources.click 
        wait_for { @driver.find_element(:css, "ul.Nav-listGroup-list--HealthTools li.Nav-listGroupSub-list-item a").displayed? }
        sleep 1
        resources_links = @driver.find_elements(:css, "ul.Nav-listGroup-list--HealthTools li.Nav-listGroupSub-list-item a")
        unless resources_links
          self.errors.add(:header, "Resources submenu links Newsletters, Medications, Videos, Clinical Trials and More tools did not appear")
        end

        if resources_links
          link_texts = resources_links.collect { |x| x.text }
          missing_links = ["Newsletters", "Medications", "Videos", "Clinical trials", "More tools"] - link_texts
          unless missing_links.length == 0
            self.errors.add(:header, "The following links were missing from the Resources submenu: #{missing_links} #{link_texts}")
          end
        end
      end

      def body_and_mind_submenu
        missing_links = []
        body_and_mind = find "ul.Nav-listGroup-list--General li.js-Nav--Primary-accordion-title"
        if body_and_mind
          body_and_mind.click 
          wait_for { @driver.find_element(:css, "ul.Nav-listGroup-list--General li.Nav-listGroupSub-list-item a").displayed? }
          wait_for { @driver.find_element(:link_text, "Sleep Disorders").displayed? }
          body_links = @driver.find_elements(:css, "ul.Nav-listGroup-list--General li.Nav-listGroupSub-list-item a")
          unless body_links
            self.errors.add(:header, "Body And Mind submenu links did not appear")
          end

          if body_links
            link_texts = body_links.collect { |x| x.text }
            missing_links = HealthCentralPage::SUB_CATEGORIES - link_texts
            unless missing_links.length == 0
              self.errors.add(:header, "Missing from Body & Mind submenu: #{missing_links}")
            end
          end
        end
      end

      def family_health
        missing_links = []
        family_health = find "ul.Nav-listGroup-list--Featured li.js-Nav--Primary-accordion-title"
        if family_health
          family_health.click
          wait_for { @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured  li.Nav-listGroupSub-list-item a").length == 2 }
          family_links = @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured  li.Nav-listGroupSub-list-item a")
          unless family_links
            self.errors.add(:header, "Missing family health links")
          end
          if family_links
            link_texts = family_links.collect { |x| x.text }
            missing_links = ['Menopause', 'Prostate'] - link_texts
            unless missing_links.length == 0
              self.errors.add(:header, "MIssing from Family Health submenu: #{missing_links}")
            end
          end
        end
      end
    end
  end

  class MobileRedesignHeader < MobileHeader
    include ::ActiveModel::Validations

    validate :subcategory_navigation

    def initialize(args)
      @driver         = args[:driver]
      @sub_category   = args[:sub_category]
      @related        = args[:related_links]
    end

    def subcategory_navigation
      subcategory   = find "a.Page-category-titleLink"
      related_links = @driver.find_elements(:css, "ul.Page-category-related-list a")

      unless subcategory
        self.errors.add(:header, "#{@subcategory} did not appear in the header")
      end
      unless related_links
        self.errors.add(:header, "#{@related_links} did not appear in the header")
      end
      if subcategory
        unless subcategory.text == @sub_category
          self.errors.add(:header, "#{@sub_category} did not appear in the header")
        end
      end
      if related_links
        related_links_text = related_links.collect {|x| x.text }
        unless related_links_text == @related
          self.errors.add(:header, "expected #{@related} to appear in the header, not #{related_links_text}")
        end
      end
    end
  end

  class LBLNMobile < MobileHeader
    include ::ActiveModel::Validations

    validate :logo
    validate :title_link
    validate :more_on_link

    def initialize(args)
      @driver       =args[:driver]
      @logo         = args[:logo]
      @title_link   = args[:title_link]
      @more_on_link = args[:more_on_link]
      @subcategory  = args[:sub_category]
      @related      = args[:related]
    end

    def logo
      logo = find ".Logo-supercollection img"
      logo_img = logo.attribute('src') if logo
      unless logo_img == @logo
        self.errors.add(:header, "Logo image src was #{logo_img} not #{@logo}")
      end
    end

    def title_link
      title_link = find "a.title-supercollection"
      title_text = title_link.text if title_link
      unless title_text == @title_link
        self.errors.add(:header, "Title link was #{title_text} not #{@title_link}")
      end
    end

    def more_on_link
      more_on_link = find "span.more-supercollection"
      link         = more_on_link.text if more_on_link
      unless link == @more_on_link
        self.errors.add(:header, "More on link was #{link} not #{@more_on_link}")
      end
    end
  end

  class SPMobile < MobileHeader
    include ::ActiveModel::Validations

    # validate :logo
    validate :title_link
    # validate :more_on_link

    def initialize(args)
      @driver       =args[:driver]
      @logo         = args[:logo]
      @title_link   = args[:title_link]
      @more_on_link = args[:more_on_link]
      @subcategory  = args[:sub_category]
      @related      = args[:related]
    end

    def logo
      logo = find ".Logo-supercollection img"
      logo_img = logo.attribute('src') if logo
      unless logo_img == @logo
        self.errors.add(:header, "Logo image src was #{logo_img} not #{@logo}")
      end
    end

    def title_link
      title_link = find "a.title-supercollection"
      title_text = title_link.text if title_link
      unless title_text == @title_link
        self.errors.add(:header, "Title link was #{title_text} not #{@title_link}")
      end
    end

    def more_on_link
      more_on_link = find "span.more-supercollection"
      link         = more_on_link.text if more_on_link
      unless link == @more_on_link
        self.errors.add(:header, "More on link was #{link} not #{@more_on_link}")
      end
    end
  end

  class DailyDoseMobile < MobileHeader
    validate :week_is_displayed

    def initialize(args)
      @driver = args[:driver]
    end

    def week_is_displayed

    end
  end
end