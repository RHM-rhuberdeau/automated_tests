require_relative '../../../minitest_helper' 
require_relative '../../../pages/redesign_entry_page'

class UnderstandingMigrainesTest < MiniTest::Test
  context "understanding-migraines sponsored topic" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/sponsoredtopics.yml')
      topic_fixture = YAML::load_documents(io)
      @topic_fixture = OpenStruct.new(topic_fixture[0]['migraines'])
      @page = ::RedesignEntry::RedesignEntryPage.new(@driver, @proxy, @topic_fixture)
      visit "#{HC_BASE_URL}/migraine/d/understanding-migraines/taking-control"
    end 

    context "when functioning properly" do 
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

    # ##################################################################
    # ################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Chronic Migraine Control and Maintenance - Migraine"), "Page title was: #{@page.driver.title}")
      end
    end

    # #########################################################################
    # ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics and omniture" do 
      should "have an adsite value of cm.own.tcc" do
        ad_site = evaluate_script("AD_SITE")
        assert_equal(true, (ad_site == "cm.own.tcc"))
      end

      should "have ad_categories value of ['zecuity', '', '']" do 
        expected_ad_categories = ["zecuity", "", ""]
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
  end
  
  def teardown  
    @driver.quit  
    @proxy.close
  end 
end