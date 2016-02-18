require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class MyMomentEpilepsy < MiniTest::Test
  context "taking control of epilepsy landing page" do 
    setup do 
      capybara_with_phantomjs
      io            = File.open('test/fixtures/healthcentral/mm.yml')
      mm_fixture    = YAML::load_documents(io)
      @mm_fixture   = OpenStruct.new(mm_fixture[0]['epilepsy'])
      @page = ::RedesignEntry::RedesignEntryPage.new(:driver => @driver,:proxy => @proxy,:fixture => @mm_fixture)
      @url  = "#{HC_BASE_URL}/epilepsy/d/living-with/taking-control" + $_cache_buster
      preload_page @url
      visit @url
      sleep 3
    end

    context "when fucntioning properly" do 
      should "have relative links in the content" do 
        links = (all(:css, ".Node-content-primary")).collect{|x| x[:href]}.compact
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
        assets = @page.assets(:base_url => @url)
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
      should "not have any errors" do 
        pharma_safe             = true
        ad_site                 = "cm.ver.epilepsy"
        ad_categories           = ["mymoment", "", ""]
        ads                     = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                                     :proxy => @proxy, 
                                                                     :url => @url,
                                                                     :ad_site => ad_site,
                                                                     :ad_categories => ad_categories,
                                                                     :exclusion_cat => "",
                                                                     :sponsor_kw => '',
                                                                     :thcn_content_type => "topics",
                                                                     :thcn_super_cat => "Body & Mind",
                                                                     :thcn_category => "Brain and Nervous System",
                                                                     :ugc => "n")
        ads.validate

        omniture = @page.omniture(:url => @url)
        omniture.validate
        assert_equal(true, (ads.errors.empty? && omniture.errors.empty?), "#{@url}: #{ads.errors.messages} #{omniture.errors.messages}")
      end
    end
  end#taking control of epilepsy landing page

  def teardown  
    cleanup_capybara
  end 
end