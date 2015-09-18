require_relative './berkeley_page'

module BerkeleySlideshow
  class SlideshowPage < BerkeleyPage
    attr_reader :driver, :proxy

    def initialize(args)
    	@driver = args[:driver]
    	@proxy	= args[:proxy]
    	@old_ad_calls = []
    end

    def seo
      SEO.new(:driver => @driver)
    end

    def old_ad_calls
    	@old_ad_calls
    end

    def old_ad_calls=(value)
    	@old_ad_calls = value
    end

    def slideshow
    	driver.find_elements(:css, "ul.slides").first
    end

    def slides
    	driver.find_elements(:css, "div.flex-viewport ul.slides li")
    end

    def ads_on_page
    	all_ads = all_ad_calls
    	current_ad_calls = all_ads - old_ad_calls
    	old_ad_calls = all_ads
    	current_ad_calls
    end

    def all_ad_calls
    	all_ad_calls = []
    	proxy.har.entries.find do |entry|
    	  if entry.request.url.include?('ad.doubleclick.net/N3965')
    	  	all_ad_calls << entry.request.url
    	  end
    	end
    	all_ad_calls
    end
  end

  class SEO
    include ::ActiveModel::Validations

    validate :one_canonical_link

    def initialize(args)
      @driver = args[:driver]
    end

    def one_canonical_link
      #Yes this is actually necessary
      #Apparently <link> and <a> are found separately

      link_tags   = @driver.find_elements(:css, "link")
      anchor_tags = @driver.find_elements(:css, "a")
      all_links   = link_tags + anchor_tags
      all_links   = all_links.select { |x| x.attribute('rel') == "canonical"}.compact
      unless all_links.length == 1
        self.errors.add(:seo, "Expected one canonical link not #{all_links.length}")
      end
    end
  end
end