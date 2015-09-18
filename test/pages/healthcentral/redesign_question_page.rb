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

    def functionality
      Functionality.new(:driver => @driver)
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
end