require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class MigraineTrackerTest < MiniTest::Test 
  context "Migrain Tracker" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::RedesignEntry::RedesignEntryPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/migraine/d/tracker-start"
    end

    context "When functioning properly" do 
      should "have relatlive links in the header" do 
        links = (@driver.find_elements(:css, ".js-HC-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end
    end
    ##################################################################
    ################### ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end

    ##################################################################
    ################### SEO ##########################################
    context "SEO safe" do 
      should "have the correct title" do 
        seo = @page.seo(:driver => @driver) 
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "be pharma safe" do
        assert_equal(true, @page.pharma_safe?)
      end

      should "load the correct analytics file" do
        assert_equal(@page.analytics_file, true)
      end

      should "have unique ads" do 
        ads1 = @page.ads_on_page(3)
        @driver.navigate.refresh
        sleep 1
        ads2 = @page.ads_on_page(3)

        ord_values_1 = ads1.collect(&:ord).uniq
        ord_values_2 = ads2.collect(&:ord).uniq
    
        assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
        assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
        assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
      end

      # should "have valid omniture values" do 
      #   omniture = @page.omniture(:url => @url)
      #   omniture.validate
      #   assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      # end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      # should "have passing global test cases" do 
      #   global_test_cases = @page.global_test_cases
      #   global_test_cases.validate
      #   assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

      #   subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
      #   title_link = @driver.find_element(:css, ".Page-category-titleLink")
      #   sub_category_links = @driver.find_element(:link, "Anxiety")
      #   sub_category_links = @driver.find_element(:link, "Chronic Pain")
      #   sub_category_links = @driver.find_element(:link, "Depression")
      #   sub_category_links = @driver.find_element(:link, "Sleep Disorders")

      #   button = @driver.find_element(:css, ".Button--Ask")
      #   button.click
      #   wait_for { @driver.find_element(css: '.titlebar').displayed? }
      #   assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/migraine/c/question", "Ask a Question linked to #{@driver.current_url} not /migraine/c/question")
      # end
    end
  end
  def teardown  
    @driver.quit  
    @proxy.close
  end 
end