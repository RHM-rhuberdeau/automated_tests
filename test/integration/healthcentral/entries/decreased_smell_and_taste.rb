require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_entry_page'

class DecreasedSmellAndTastePageTest < MiniTest::Test
  context "a health pro member entry" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/entries.yml')
      entry_fixture = YAML::load_documents(io)
      @entry_fixture = OpenStruct.new(entry_fixture[0][173667])
      @page = ::RedesignEntry::RedesignEntryPage.new(@driver, @proxy, @entry_fixture)
      visit "#{HC_BASE_URL}/allergy/c/3989/173667/decreased-common-bedfellows"
    end

    context "when functioning properly" do 
      should "have the publish date" do 
        publish_date = @driver.find_element(:css, "span.Page-info-publish-date").text
        expected_date = "December 22, 2014"
        assert_equal(expected_date, publish_date, "publish date was #{publish_date} not #{expected_date}")
      end

      should "include the authors name in the byline" do 
        author_name = @driver.find_element(:css, ".Page-info-publish-author a").text
        expected_name = "James Thompson, MD"
        assert_equal(expected_name, author_name, "author name was #{author_name} not #{expected_name}")
      end

      should "include the author's role" do  
        role = @driver.find_element(:css, "span.Page-info-publish-badge").text
        expected_role = "Health Pro"
        assert_equal(expected_role, role, "role was #{role} not #{expected_role}")
      end
      
      should "include the author's profile image which links to the author's profile" do 
        profile_img = @driver.find_element(:css, "a.Page-info-visual img")
        assert_equal(true, !profile_img.nil?)
        profile_img.click
        assert_equal(true, (@driver.current_url == "#{HC_BASE_URL}/profiles/c/3989"))
      end

      should "not have nofollow tags on any links the expert posted" do 
        "ul.ContentList--blogpost a"
        post_links = @driver.find_elements(:css, "ul.ContentList--blogpost a")
        assert_equal(true, (post_links.length > 0), "no links in the expert's post")
        links_with_no_follow = post_links.map do |link|
          if link.attribute('rel') && link.attribute('rel') == 'nofollow'
            link.text
          end
        end
        links_with_no_follow = links_with_no_follow.compact
        assert_equal(true, links_with_no_follow.empty?, "Expert post had links with nofollow: #{links_with_no_follow}")
      end

      should "have relatlive links in the header" do 
        links = (@driver.find_elements(:css, ".js-HC-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end

      should "have relative links in the right rail" do 
        wait_for { @driver.find_element(:css, ".MostPopular-container").displayed? }
        links = (@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link 
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
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, @page.has_correct_title?)
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

      should "have valid omniture values" do 
        omniture = @page.omniture
        omniture.validate
        assert_equal(true, omniture.errors.empty?, "#{omniture.errors.messages}")
      end
    end

    ##################################################################
    ################### GLOBAL SITE TESTS ############################
    context "Global Site tests" do 
      should "have passing global test cases" do 
        global_test_cases = @page.global_test_cases
        global_test_cases.validate
        assert_equal(true, global_test_cases.errors.empty?, "#{global_test_cases.errors.messages}")

        subnav = @driver.find_element(:css, "div.Page-category.Page-sub-category.js-page-category")
        title_link = @driver.find_element(:css, ".Page-category-titleLink")
        sub_category_links = @driver.find_element(:link, "Asthma")
        sub_category_links = @driver.find_element(:link, "Cold & Flu")
        sub_category_links = @driver.find_element(:link, "Skin Care")

        button = @driver.find_element(:css, ".Button--Ask")
        button.click
        wait_for { @driver.find_element(css: '.titlebar').displayed? }
        assert_equal(true, @driver.current_url == "#{HC_BASE_URL}/allergy/c/question", "Ask a Question linked to #{@driver.current_url} not /allergy/c/question")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end