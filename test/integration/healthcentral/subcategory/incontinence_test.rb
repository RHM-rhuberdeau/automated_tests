require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_question_page'

class SubCategory < MiniTest::Test
  context "incontinence" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/subcategories.yml')
      subcat_fixture = YAML::load_documents(io)
      @subcat_fixture = OpenStruct.new(subcat_fixture[0]['incontinence'])
      @page = ::HealthCentralPage.new(@driver, @proxy, @subcat_fixture)
      visit "#{HC_DRUPAL_URL}/incontinence"
    end

    context "when functioning properly" do 
      should "have a title in each latest post" do 
        sleep 3
        latest_post_titles = @driver.find_elements(:css, "span.Teaser-title")
        assert_equal(true, (latest_post_titles.length > 0), "No Latest posts")
        latest_post_titles = latest_post_titles.collect(&:text)
        assert_equal(true, (latest_post_titles.length > 0), "No Latest posts")
        latest_post_titles = latest_post_titles.map {|p| p.gsub(" ", "") }.map {|p| p.gsub("...", "")}
        latest_post_titles.each do |title|
          assert_equal(true, (title.length > 0), "Blank title for latest post: #{latest_post_titles}")
        end
      end

      should "have a hero post" do 
        hero_image = @driver.find_element(:css, "div.HeroBox a img")
        hero_link  = @driver.find_elements(:css, "div.HeroBox a").last
        hero_link_text = hero_link.text
        assert_equal(true, !hero_image.nil?, "No hero post image")
        assert_equal(true, !hero_link.nil?, "No hero post link")
        assert_equal(true, hero_link_text.length > 0, "No hero post text: #{hero_link_text}")
      end

      should "have a we recommend section with 3 posts" do 
        we_recommend_text = @driver.find_element(:css, "h4").text
        posts = @driver.find_elements(:css, "ul.CollectionListBoxes-list")
        post_images = @driver.find_elements(:css, "ul.CollectionListBoxes-list li a img")
        post_links  = @driver.find_elements(:css, "ul.CollectionListBoxes-list li a")
        post_titles = post_links.collect(&:text)

        assert_equal(3, post_images.length)
        assert_equal(3, post_links.length)
        assert_equal(3, post_titles.length)
        post_titles.each do |title|
          assert_equal(true, title.length > 0, "Missing title in we recommend post")
        end
      end

      should "show up to 15 more latest posts" do 
        2.times do 
          wait_for { @driver.find_element(:css, ".js-CollectionEditorsPicks-view-more").displayed? }
          button = @driver.find_element(:css, ".js-CollectionEditorsPicks-view-more")
          button.click
          wait_for { !@driver.find_element(:css, ".spinner-container").displayed? }
          sleep 0.5
        end
        editor_picks = @driver.find_elements(:css, ".Editor-picks-item")
        begin
          sponsored_picks = @driver.find_elements(:css, ".Editor-picks-item.u-pullLeft.sponsored.sponsor-bg")
        rescue
          sponsored_picks = []
        end
        assert_equal(true, ((editor_picks.length - sponsored_picks.length) == 15), "#{editor_picks.length} appeared, not 15")
      end

      should "have a more resources section" do 
        text  = @driver.find_element(:css, ".Moreresources h1.Block-title").text
        links = @driver.find_elements(:css, ".Moreresources-container ul li a")
        links_text = links.collect(&:text)

        assert_equal(true, text.downcase == "more resources", "text was #{text} not More Resources")
        assert_equal(7, links.length, "#{links.length} appeared in more resources, not 7")
        links_text.each do |text|
          assert_equal(true, (text == "Slideshows" || text == "Medications" || text == "Videos" || text == "Questions" || text == "Topics A-Z" || text == "Quizzes and Assessments" || text == "Blogposts"), "#{text} did not appear in more resources")
        end
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

    # ##################################################################
    # ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Urinary Incontinence: Stress, Urge, Female, Male, Causes, Treatment | www.healthcentral.com"), "Page title was: #{@page.driver.title}")
      end
    end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics and omniture" do 
      should "have an adsite value of cm.ver.incontinence" do 
        ad_site = evaluate_script("AD_SITE")
        assert_equal(true, (ad_site == "cm.ver.incontinence"), "ad_site was #{ad_site} not cm.ver.incontinence")
      end

      should "have ad_categories value of ['home', '', '']" do 
        expected_ad_categories = ["home", "", ""]
        actual_ad_categories   = evaluate_script("AD_CATEGORIES")
        assert_equal(true, (actual_ad_categories == expected_ad_categories), "ad_categories was #{actual_ad_categories} not #{expected_ad_categories}")
      end

      should "have unique ads" do 
        ads1 = @page.ads_on_page
        @driver.navigate.refresh
        sleep 1
        ads2 = @page.ads_on_page

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
    context "global site requirements" do
      should "have a promo item in the right rail" do 
        wait_for { @driver.find_element(:css, ".RightrailbuttonpromoItem").displayed? }
        promo_img = @driver.find_element(:css, ".RightrailbuttonpromoItem a img")
        promo_text = @driver.find_elements(:css, ".RightrailbuttonpromoItem a").last.text

        assert_equal(true, !promo_img.nil?, "promo image did not appear on the page")
        assert_equal(true, promo_text.length > 0, "promo link text did not appear on the page")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end