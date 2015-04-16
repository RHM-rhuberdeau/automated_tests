require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_entry_page'

class LBLN < MiniTest::Test
  context "taking control of epilepsy landing page" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/mm.yml')
      mm_fixture = YAML::load_documents(io)
      @mm_fixture = OpenStruct.new(mm_fixture[0]['epilepsy'])
      @page = ::RedesignEntry::RedesignEntryPage.new(@driver, @proxy, @mm_fixture)
      visit "#{HC_BASE_URL}/epilepsy/d/living-with/taking-control"
    end

    context "when fucntioning properly" do 
      should "have relatlive links in the header" do 
        links = (@driver.find_elements(:css, ".Page-supercollection-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end

      should "have relative links in the right rail" do 
        links = (@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link 
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end

      should "have relative links in the content" do 
        links = (@driver.find_elements(:css, ".Node-content-primary")).collect{|x| x.attribute('href')}.compact
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

      should "have an adsite value of cm.ver.epilepsy" do 
        ad_site = evaluate_script("AD_SITE")
        assert_equal(true, (ad_site == "cm.ver.epilepsy"), "ad_site was #{ad_site} not cm.ver.epilepsy")
      end

      should "have ad_categories value of ('', '', '')" do 
        expected_ad_categories = ["mymoment", "", ""]
        actual_ad_categories   = evaluate_script("AD_CATEGORIES")
        assert_equal(true, (actual_ad_categories == expected_ad_categories), "ad_categories was #{actual_ad_categories} not #{expected_ad_categories}")
      end

      should "have unique ads" do 
        ads1 = @page.ads_on_page(3)
        visit "#{HC_BASE_URL}/epilepsy/d/living-with/taking-control"
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
  end#taking control of epilepsy landing page

  # context "taking control of epilepsy immersive" do 
  #   setup do 
  #     fire_fox_with_secure_proxy
  #     @proxy.new_har
  #     io = File.open('test/fixtures/healthcentral/mm.yml')
  #     mm_fixture = YAML::load_documents(io)
  #     @mm_fixture = OpenStruct.new(mm_fixture[0]['epilepsy'])
  #     @page = ::RedesignEntry::RedesignEntryPage.new(@driver, @proxy, @mm_fixture)

  #     visit "#{IMMERSIVE_URL}/epilepsy/d/LBLN/living-with-epilepsy/flat/?ic=hero"
  #   end

  #   # Immersive pages themselves are not a problem. This only needs to be run in production
  #   should "have an adsite value of cm.ver.epilepsy" do 
  #     ad_site = evaluate_script("AD_SITE")
  #     assert_equal(true, (ad_site == "cm.ver.epilepsy"), "ad_site was #{ad_site} not cm.ver.epilepsy")
  #   end

  #   should "have ad_categories value of ['mymoment', 'chapter0']" do 
  #     expected_ad_categories = ['mymoment', 'chapter0']
  #     actual_ad_categories   = evaluate_script("AD_CATEGORIES")
  #     assert_equal(true, (actual_ad_categories == expected_ad_categories), "ad_categories was #{actual_ad_categories} not #{expected_ad_categories}")
  #   end

  #   should "have unique ads" do 
  #     sleep 0.5
  #     ads1 = @page.ads_on_page(:length => 1)
  #     @driver.navigate.refresh
  #     sleep 0.5
  #     ads2 = @page.ads_on_page(:start => -1, :length => 1)

  #     ord_values_1 = ads1.collect(&:ord).uniq
  #     ord_values_2 = ads2.collect(&:ord).uniq

  #     assert_equal(1, ord_values_1.length, "Ads on the first view had multiple ord values: #{ord_values_1}")
  #     assert_equal(1, ord_values_2.length, "Ads on the second view had multiple ord values: #{ord_values_2}")
  #     assert_equal(true, (ord_values_1[0] != ord_values_2[0]), "Ord values did not change on page reload: #{ord_values_1} #{ord_values_2}")
  #   end

  #   should "have the correct title" do 
  #     assert_equal(true, @page.has_correct_title?)
  #   end

  #   should "have relatlive links in the header" do 
  #     links = (@driver.find_elements(:css, ".Page-supercollection-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
  #     bad_links = links.map do |link|
  #       if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
  #         link unless link.include?("twitter")
  #       end
  #     end
  #     assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
  #   end

  #   should "have relative links in the right rail" do 
  #     links = (@driver.find_elements(:css, ".Node-content-secondary a") + @driver.find_elements(:css, ".MostPopular-container a")).collect{|x| x.attribute('href')}.compact
  #     bad_links = links.map do |link|
  #       if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
  #         link 
  #       end
  #     end
  #     assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
  #   end

  #   should "have relative links in the content" do 
  #     links = (@driver.find_elements(:css, ".Node-content-primary")).collect{|x| x.attribute('href')}.compact
  #     bad_links = links.map do |link|
  #       if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
  #         link unless link.include?("twitter")
  #       end
  #     end
  #     assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
  #   end 

  #   ##################################################################
  #   ################### ASSETS #######################################
  #   context "assets" do 
  #     should "have valid assets" do 
  #       assets = @page.assets
  #       assets.validate
  #       assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
  #     end
  #   end
  # end#taking control of epilepsy immersive

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end