module TheBodyHeader
  class ArticleHeader
    include ::ActiveModel::Validations

    validate :header_navbar

    def initialize(args)
      @driver = args[:driver]
    end

    def header_navbar
      logo                = find "div.header-table.header-top-row a#header-logo img"
      first_header_cell   = @driver.find_elements(:css, "div.header-table.header-top-row div.header-cell a.bordered")
      if first_header_cell
        first_header_cell = first_header_cell.select {|x| x.displayed?}
      end
      social_buttons = []
      bottom_header_row   = @driver.find_elements(:css, "div.header-table.header-bottom-row a")

      unless logo
        self.errors.add(:header, "Body log was missing from the head nav")
      end
      unless first_header_cell.length == 5
        self.errors.add(:header, "Expected 5 links in the first header cell not #{first_header_cell.length}")
      end
      unless bottom_header_row.length == 6
        self.errors.add(:header, "Expected 6 links in the bottom header row not #{bottom_header_row.length}")
      end
    end
  end

  class RedesignHeader
    include ::ActiveModel::Validations

    validate :targeted_populations
    validate :primary_site_sections
    validate :social_buttons
    validate :patient_journey_nav

    def initialize(args)
      @driver = args[:driver]
    end

    def targeted_populations
      expected_links  = ['Gay Men', 'Women', 'African Americans', 'Latinos', 'Aging', 'More...']
      links           = @driver.find_elements(:css, "#navbar-content > div > div.header-table.header-top-row > div:nth-child(2) a")
      links           = links.select {|x| x.displayed? }
      if links 
        link_texts = links.collect { |x| x.text } 
      else
        link_texts = []
      end
      expected_links.each do |link|
        unless link_texts.include?(link)
          self.errors.add(:header, "Targeted populations was missing the #{link} link")
        end
      end
    end

    def primary_site_sections
      expected_links  = ['JUST DIAGNOSED', 'HIV PREVENTION', 'HIV TREATMENT', 'LIVING WELL', 'COMMUNITY', 'ASK THE EXPERTS']
      links           = @driver.find_elements(:css, ".header-table.header-bottom-row a")
      links           = links.select {|x| x.displayed? }
      if links 
        link_texts = links.collect { |x| x.text } 
      else
        link_texts = []
      end
      expected_links.each do |link|
        unless link_texts.include?(link)
          self.errors.add(:header, "Primary site section was missing the #{link} link")
        end
      end
    end

    def social_buttons
      fb      = find "#navbar-content .HC-header-socialButtons .js-Social--Follow-actionable-facebook"
      twitter = find "#navbar-content .HC-header-socialButtons .js-Social--Follow-actionable-twitter" 
      news    = find "#navbar-content .HC-header-socialButtons .js-Social--Follow-actionable-newsletters"

      unless fb
        self.errors.add(:header, "Header was missing the FB social share icon")
      end
      unless twitter
        self.errors.add(:header, "Header was missing the Twitter social share icon")
      end
      unless news
        self.errors.add(:header, "Header was missing the Newsletter social share icon")
      end
    end

    def patient_journey_nav
      buttons = @driver.find_elements(:css, "a.Button--AZ.js-HC-nav-action")
      buttons.first.click if buttons
      wait_for { @driver.find_element(:css, "ul.Nav-listGroup-list--Featured").displayed? }

      health_tools_links  = @driver.find_elements(:css, "ul.Nav-listGroup-list--HealthTools a")
      general_links       = @driver.find_elements(:css, "ul.Nav-listGroup-list--General a")
      featured_links      = @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured a")

      unless health_tools_links.length == 8
        self.errors.add(:header, "Health tools section was missing links")
      end
      unless general_links.length == 36
        self.errors.add(:header, "General links section was missing links")
      end
      unless featured_links.length == 8
        self.errors.add(:header, "Featured links section was missing links")
      end
    end
  end

  class RedesignMobileHeader
    include ::ActiveModel::Validations

    validate :targeted_populations
    validate :primary_site_sections
    validate :social_buttons
    # validate :patient_journey_nav

    def initialize(args)
      @driver = args[:driver]
    end

    def targeted_populations
      hamburger = find "#header-hamburger"
      hamburger.click if hamburger
      wait_for { @driver.find_element(:css, "#header-menu .section.resource-centers a").displayed? }

      expected_links  = ['Gay Men', 'Women', 'African Americans', 'Latinos', 'Aging', 'More...']
      links           = @driver.find_elements(:css, "#header-menu .section.resource-centers a")
      links           = links.select {|x| x.displayed? }
      if links 
        link_texts = links.collect { |x| x.text } 
      else
        link_texts = []
      end
      expected_links.each do |link|
        unless link_texts.include?(link)
          self.errors.add(:header, "Targeted populations was missing the #{link} link")
        end
      end
    end

    def primary_site_sections
      expected_links  = ['JUST DIAGNOSED', 'HIV PREVENTION', 'HIV TREATMENT', 'LIVING WELL', 'COMMUNITY', 'ASK THE EXPERTS']
      links           = @driver.find_elements(:css, "#header-menu .section.portals a")
      links           = links ? links.select  { |x| x.displayed? } : nil
      link_texts      = links ? links.collect { |x| x.text }       : []

      expected_links.each do |link|
        unless link_texts.include?(link)
          self.errors.add(:header, "Primary site section was missing the #{link} link")
        end
      end
    end

    def social_buttons
      fb      = find "div.bottom-social-bar .social-icon span.icon-facebook"
      twitter = find "div.bottom-social-bar .social-icon span.icon-twitter" 
      news    = find "div.bottom-social-bar .social-icon-mail"

      unless fb
        self.errors.add(:header, "Header was missing the FB social share icon")
      end
      unless twitter
        self.errors.add(:header, "Header was missing the Twitter social share icon")
      end
      unless news
        self.errors.add(:header, "Header was missing the Newsletter social share icon")
      end
    end

    def patient_journey_nav
      buttons = @driver.find_elements(:css, "a.Button--AZ.js-HC-nav-action")
      begin
        buttons.first.click if buttons
      rescue Selenium::WebDriver::Error::ElementNotVisibleError
      end

      wait_for { @driver.find_element(:css, "ul.Nav-listGroup-list--Featured").displayed? }

      health_tools_links  = @driver.find_elements(:css, "ul.Nav-listGroup-list--HealthTools a")
      general_links       = @driver.find_elements(:css, "ul.Nav-listGroup-list--General a")
      featured_links      = @driver.find_elements(:css, "ul.Nav-listGroup-list--Featured a")

      health_tools_links  = health_tools_links ? health_tools_links.select {|x| x.displayed? } : []
      general_links       = general_links ? general_links.select {|x| x.displayed? } : []
      featured_links      = featured_links ? featured_links.select {|x| x.displayed? } : []

      unless health_tools_links.length == 8
        self.errors.add(:header, "Health tools section was missing links")
      end
      unless general_links.length == 36
        self.errors.add(:header, "General links section was missing links")
      end
      unless featured_links.length == 8
        self.errors.add(:header, "Featured links section was missing links")
      end
    end
  end#RedesignMobileHeader

  class TheBodyPro
    include ::ActiveModel::Validations

    validate :logo
    validate :nav_links

    def initialize(args)
      @driver = args[:driver]
    end

    def logo
      body_logo = find "#topnav > table:nth-child(2) > tbody > tr:nth-child(1) > td:nth-child(1) > a > img"
      unless body_logo
        self.errors.add(:header, "Missing the logo in the header")
      end
    end

    def nav_links
      links = @driver.find_elements(:css, "div#topnav table.navlinks a")
      unless links
        self.errors.add(:header, "Nav links missing in the header")
      end
      if links
        unless links.length == 10
          self.errors.add(:header, "Expected 8 links in the header, not #{links.length}")
        end
      end
    end
  end

  class TheBodyProArchived
    include ::ActiveModel::Validations

    validate :logo
    validate :nav_links

    def initialize(args)
      @driver = args[:driver]
    end

    def logo
      body_logo = find "#header div#logo img"
      unless body_logo
        self.errors.add(:header, "Missing the logo in the header")
      end
    end

    def nav_links
      links = @driver.find_elements(:css, "div#navwrapper a")
      unless links
        self.errors.add(:header, "Nav links missing in the header")
      end
      if links
        unless links.length == 8
          self.errors.add(:header, "Expected 8 links in the header, not #{links.length}")
        end
      end
    end
  end
end