require_relative './healthcentral_page'

module RedesignQuestion
  class RedesignQuestionPage < HealthCentralPage
    attr_reader :driver, :proxy

    def initialize(args)
    	@driver = args[:driver]
    	@proxy	= args[:proxy]
      @fixture = args[:fixture]
      @ads  = []
    end

    def global_test_cases
      RedesignQuestion::GlobalTestCases.new(@driver, @proxy)
    end

    def functionality
      Functionality.new(:driver => @driver)
    end

    def assets
      all_images = @driver.find_elements(tag_name: 'img')
      HealthCentralAssets::Assets.new(:proxy => @proxy, :imgs => all_images)
    end

    def omniture
      @driver.execute_script "javascript:void(window.open(\"\",\"dp_debugger\",\"width=600,height=600,location=0,menubar=0,status=1,toolbar=0,resizable=1,scrollbars=1\").document.write(\"<script language='JavaScript' id=dbg src='https://www.adobetag.com/d1/digitalpulsedebugger/live/DPD.js'></\"+\"script>\"))"
      sleep 1
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      omniture_text = @driver.find_element(:css, 'td#request_list_cell').text
      omniture = HealthCentralOmniture::Omniture.new(omniture_text, @fixture)
    end

    def analytics_file
    	has_file = false
      proxy.har.entries.each do |entry|
        if entry.request.url.include?('namespace.js')
          has_file = true
        end
      end
      has_file
    end

    def pharma_safe?
    	(driver.execute_script("return EXCLUSION_CAT") != 'community') && (driver.execute_script("return pharmaSafe") == true)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :community_answers_truncated
    validate :display_full_community_answer

    def initialize(args)
      @driver = args[:driver]
    end

    def community_answers_truncated
      view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
      view_more_answers.click
      wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }
      first_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '').gsub("READ MORE", '')
      unless first_answer.length == 280
        self.errors.add(:base, "Community answer was not truncated")
      end
    end

    def display_full_community_answer
      view_more_answers = @driver.find_elements(:css, "a.Button--highlight.js-view-more-answers").first
      view_more_answers.click
      wait_for { @driver.find_element(css: '.QA-community .CommentBox-secondary-content').displayed? }
      truncated_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
      read_more = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content .js-read-more").select { |x| x.displayed? }.first
      read_more.click
      sleep 0.5
      full_answer = @driver.find_elements(:css, ".QA-community .CommentBox-secondary-content").first.text.gsub(" ", '').gsub("\n", '')
      unless truncated_answer != full_answer
        self.errors.add(:base, "Full answer was the same as the truncated answer")
      end
    end
  end

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :health_logo
    validate :health_az_menu
    validate :social_icons
    validate :subcategory_navigation
    validate :footer

    def initialize(driver, proxy)
      @driver = driver
      @proxy  = proxy
    end

    def health_logo
      logo_1 = @driver.find_element(:css, "span.LogoHC-part1")
      logo_2 = @driver.find_element(:css, "span.LogoHC-part2")

      unless (logo_1.text == "Health" && logo_2.text == "Central")
        self.errors.add(:base, "Health Logo was missing from the page")
      end

      link = @driver.find_element(:css, "a.LogoHC")
      link.click
      sleep 1
      unless @driver.current_url == "#{HC_BASE_URL}/"
        self.errors.add(:base, "The logo linked to #{@driver.current_url} not #{HC_BASE_URL}/")
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
      button.click
      wait_for { @driver.find_element(:css, ".HC-nav").displayed? }
      az_nav = @driver.find_element(:css, ".HC-nav")

      unless nav_on_pageload.empty?
        self.errors.add(:base, "A-Z was on the page before clicking it")
      end
      unless az_nav
        self.errors.add(:base, "A-Z nav did not appear on the page afer clicking the Health A-Z button")
      end

      #Check for Category Links
      wait_for { @driver.find_element(css: '.js-Nav--Primary-accordion-title').displayed? }
      titles = @driver.find_elements(:css, ".js-Nav--Primary-accordion-title").select {|x| x.displayed? }.select {|x| x.text == "BODY & MIND" || x.text == "FAMILY HEALTH" || x.text == "HEALTHY LIVING"}
      unless titles.length == 3
        self.errors.add(:base, "Not all super categories were on the page. Present were: #{titles}")
      end 

      #Check for Sub Category links
      sub_category_links      = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary .Nav-listGroup-list--General  a")
      sub_category_links_text = sub_category_links.collect {|x| x.text }
      all_links_counted_for   = ::HealthCentralPage::SUB_CATEGORIES - sub_category_links_text
      extra_links             = sub_category_links_text - ::HealthCentralPage::SUB_CATEGORIES

      unless (sub_category_links.length == ::HealthCentralPage::SUB_CATEGORIES.length && all_links_counted_for.empty?)
        self.errors.add(:base, "There were missing or extra subcategory links in the health a-z menu: #{all_links_counted_for}")
      end
      unless (extra_links.empty?)
        self.errors.add(:base, "There were extra sub_category links on the page: #{extra_links}")
      end

      ibd = @driver.find_elements(:css, ".Nav--Primary.js-Nav--Primary a").select { |x| x.text == "Digestive Health"}.first
      ibd.click
      wait_for { @driver.find_element(:css, ".Phases-navigation").displayed? }
      unless (@driver.current_url == "#{HC_BASE_URL}/ibd/" || @driver.current_url == "#{HC_BASE_URL}/ibd")
        self.errors.add(:base, "IBD linked to #{@driver.current_url} not #{HC_BASE_URL}/ibd/")
      end
      @driver.navigate.back
    end

    def social_icons
      wait_for { @driver.find_element(:css, ".HC-header-content span.icon-facebook").displayed? }
      #Check Facebook icon
      fb_icon = @driver.find_element(:css, ".HC-header-content span.icon-facebook")
      fb_icon.click
      sleep 1
      first_window  = @driver.window_handles.first
      second_window = @driver.window_handles.last
      @driver.switch_to.window second_window
      unless @driver.current_url == "https://www.facebook.com/HealthCentral"
        self.errors.add(:base, "Facebook icon linked to #{@driver.current_url} not https://www.facebook.com/HealthCentral")
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
      unless @driver.current_url == "https://twitter.com/healthcentral"
        self.errors.add(:base, "Twitter icon linked to #{@driver.current_url} not https://twitter.com/healthcentral")
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
        self.errors.add(:base, "Pinterest icon linked to #{@driver.current_url} not https://www.pinterest.com/HealthCentral/")
      end
      @driver.close
      @driver.switch_to.window first_window

      #Check Mail Icon
      mail_icon = @driver.find_element(:css, ".HC-header-content span.icon-mail")
      mail_icon.click
      sleep 1
      unless @driver.current_url == "#{HC_BASE_URL}/profiles/c/newsletters/subscribe"
        self.errors.add(:base, "Pinterest icon linked to #{@driver.current_url} not #{HC_BASE_URL}/profiles/c/newsletters/subscribe")
      end
      @driver.navigate.back
    end

    def subcategory_navigation
      fb_share          = @driver.find_element(:css, "span.icon-facebook.icon-light.js-social--share")
      twitter_share     = @driver.find_element(:css, "span.icon-twitter.icon-light.js-social--share")
      stumbleupon_share = @driver.find_element(:css, "span.icon-stumbleupon.icon-light.js-social--share")
      mail_share        = @driver.find_element(:css, "span.icon-mail.icon-light.js-social--share")
    end

    def footer
      footer_links = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "About Us" || x.text == "Contact Us" || x.text == "Privacy Policy" || x.text == "Terms of Use" || x.text == "Security Policy" || x.text == "Advertising Policy" || x.text == "Advertise With Us" }
      other_sites = @driver.find_elements(:css, "#footer a.HC-link-row-link").select { |x| x.text == "The Body" || x.text == "The Body Pro" || x.text == "Berkeley Wellness" || x.text == "Health Communities" || x.text == "Health After 50" || x.text == "Intelecare" || x.text == "Mood 24/7"}
      unless footer_links.length == 7
        self.errors.add(:base, "Links missing from footer: #{footer_links}")
      end
      unless other_sites.length == 7
        self.errors.add(:base, "Missing links to other sites in the footer: #{other_sites}")
      end
    end
  end
end