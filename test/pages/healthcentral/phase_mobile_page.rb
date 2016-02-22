require_relative './phase_page'

module Phases
  class MobilePhasePage < Phases::PhasePage
    include Capybara::DSL

    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      Functionality.new(:driver => @driver, :phase => args[:phase], :phase_navigation => args[:phase_navigation])
    end

    def global_test_cases
      GlobalTestCases.new(:driver => @driver, :head_navigation => @head_navigation, :footer => @footer)
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    validate :current_phase_highlighted
    validate :social_controls
    validate :page_description
    validate :we_recommend
    validate :latest_posts
    validate :pagination
    validate :dig_deeper

    def initialize(args)
      @driver           = args[:driver]
      @phase            = args[:phase]
      @phase_navigation = args[:phase_navigation]
    end

    def phase_navigation

    end

    def current_phase_highlighted
      highlighted       = page.find ".PhaseTitle"
      highlighted_phase = highlighted.text if highlighted
      unless highlighted
        self.errors.add(:current_phase_highlighted, "None of the phases in the Phase Navigation menu were highlighted")
      end
      unless highlighted_phase && highlighted_phase.downcase == @phase
        self.errors.add(:current_phase_highlighted, "#{highlighted_phase} was highlighted not #{@phase}")
      end
    end 

    def social_controls
      wait_for { find(:css, "div.SocialButtons--Share.is-horizontal ul.SocialButtons-list li.SocialButtons-listItem-facebook a.js-Social--Follow-actionable-Facebook").visible? }
      facebook      = find "div.SocialButtons--Share.is-horizontal ul.SocialButtons-list a.js-Social--Follow-actionable-Facebook" 
      twitter       = find "div.SocialButtons--Share.is-horizontal ul.SocialButtons-list a.js-Social--Follow-actionable-Twitter"
      pinterest     = find "div.SocialButtons--Share.is-horizontal ul.SocialButtons-list a.js-Social--Follow-actionable-Pinterest"
      stumble_upon  = find "div.SocialButtons--Share.is-horizontal ul.SocialButtons-list a.js-Social--Follow-actionable-Stumbleupon"

      unless facebook
        self.errors.add(:social_controls, "Facebook share link did not appear on the page")
      end
      unless pinterest
        self.errors.add(:social_controls, "pinterest share link did not appear on the page")
      end
      unless twitter
        self.errors.add(:social_controls, "twitter share link did not appear on the page")
      end
      unless stumble_upon
        self.errors.add(:social_controls, "stumble_upon share link did not appear on the page")
      end
    end

    def latest_posts
      latest_posts        = all(:css, ".Editor-picks-container div.Editor-picks-item.u-pullLeft")
      latest_posts_header = find "h4.Block-title" 
      header_text         = latest_posts_header.text if latest_posts_header
      latest_posts_titles = all(:css, ".Editor-picks-title-container.js-Editor-picks-title-container")
      latest_posts_titles = latest_posts_titles.select { |x| x.text.length > 0 }

      unless latest_posts.length >= 8
        self.errors.add(:latest_posts, "There were only #{latest_posts.length} modules on the page")
      end
      unless header_text == "LATEST POSTS"
        self.errors.add(:latest_posts, "LATEST POSTS did not appear on the page")
      end
      latest_posts_titles.each do |post|
        if post.text == "..."
          self.errors.add(:latest_posts, "Latest Post content title using ellipses")
        end
      end
      unless latest_posts_titles.length == latest_posts.length
        self.errors.add(:latest_posts, "One of the latest posts modules was missing a title")
      end
    end
  end

  class GlobalTestCases
    include ::ActiveModel::Validations

    validate :head_navigation
    validate :footer

    def initialize(args)
      @head_navigation = args[:head_navigation]
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