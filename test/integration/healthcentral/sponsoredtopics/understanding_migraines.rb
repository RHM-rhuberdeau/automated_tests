require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

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

    ###################################################################
    #################### SEO ##########################################
    context "SEO" do 
      should "have the correct title" do 
        assert_equal(true, (@driver.title == "Taking Control of Chronic Migraine - Migraine"), "Page title was: #{@driver.title}")
      end
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do 
        pharma_safe             = evaluate_script("EXCLUSION_CAT")
        pharma_safe             = pharma_safe == ""
        has_file                = @page.analytics_file
        ad_site                 = evaluate_script("AD_SITE")
        expected_ad_site        = "cm.own.tcc"
        expected_ad_categories  = ["zecuity", "", ""]
        actual_ad_categories    = evaluate_script("AD_CATEGORIES")
        ads                     = RedesignEntry::RedesignEntryPage::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => "#{HC_BASE_URL}/migraine/d/understanding-migraines/taking-control",
                                                                     :ad_site => ad_site,
                                                                     :expected_ad_site => expected_ad_site,
                                                                     :ad_categories => actual_ad_categories,
                                                                     :expected_ad_categories => expected_ad_categories,
                                                                     :pharma_safe => pharma_safe,
                                                                     :expected_pharma_safe => true,
                                                                     :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{ads.errors.messages} #{omniture.errors.messages}")
      end
    end
  end
  
  def teardown  
    @driver.quit  
    @proxy.close
  end 
end