require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/redesign_entry_page'

class MerckTest < MiniTest::Test
  context "merck sponsored topic" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      io = File.open('test/fixtures/healthcentral/sponsoredtopics.yml')
      topic_fixture = YAML::load_documents(io)
      @topic_fixture = OpenStruct.new(topic_fixture[0]['merck'])
      @page = ::RedesignEntry::RedesignEntryPage.new(:driver =>@driver,:proxy => @proxy,:fixture => @topic_fixture)
      @url  = "#{HC_BASE_URL}/skin-cancer/d/treatment/stage-iv-melanoma" + "?foo=#{rand(36**8).to_s(36)}"
      visit @url
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
        pharma_safe    = true
        has_file       = @page.analytics_file
        ad_site        = "cm.own.tcc"
        ad_categories  = ["merck", "", ""]
        ads            = HealthCentralAds::AdsTestCases.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => @url,
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => "",
                                                            :sponsor_kw => '',
                                                            :thcn_content_type => "topics",
                                                            :thcn_super_cat => "Body & Mind",
                                                            :thcn_category => "Cancer",
                                                            :ugc => "[\"n\"]") 
        ads.validate

        omniture = @page.omniture(:url => @url)
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