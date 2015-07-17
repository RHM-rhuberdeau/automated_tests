require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/fdb_mobile_page'

class FdbMedicationsIndexPageTest < MiniTest::Test
  context "acid reflux mobile" do 
    setup do 
      mobile_fire_fox_with_secure_proxy
      @proxy.new_har
      io                = File.open('test/fixtures/healthcentral/fdb.yml')
      fixture           = YAML::load_documents(io)
      fdb_fixture       = OpenStruct.new(fixture[0]['acid_reflux_mobile'])
      head_navigation   = HealthCentralHeader::MobileRedesignHeader.new(:logo => "#{ASSET_HOST}/sites/all/themes/healthcentral/images/logo_lbln.png", 
                                   :sub_category => "Digestive Health",
                                   :related_links => ['Acid Reflux'],
                                   :driver => @driver)
      footer            = HealthCentralFooter::RedesignFooter.new(:driver => @driver)
      @page             = FDB::FDBMobilePage.new(:driver => @driver,:proxy => @proxy,:fixture => fdb_fixture, :head_navigation => head_navigation, :footer => footer, :collection => false)
      visit "#{HC_BASE_URL}/acid-reflux/medications"
    end

    #########################################################################
    ################### ADS, ANALYTICS, OMNITURE ############################
    context "ads, analytics, omniture" do
      should "not have any errors" do
        ad_site           = 'cm.ver.acidreflux'
        ad_categories     = ["medications", "", '']
        exclusion_cat     = ""
        sponsor_kw        = ''
        thcn_content_type = "Drug"
        thcn_super_cat    = "Body & Mind"
        thcn_category     = "Digestive Health"
        ads               = FDB::FDBMobilePage::LazyLoadedAds.new(:driver => @driver,
                                                            :proxy => @proxy, 
                                                            :url => "#{HC_BASE_URL}/acid-reflux/medications",
                                                            :ad_site => ad_site,
                                                            :ad_categories => ad_categories,
                                                            :exclusion_cat => exclusion_cat,
                                                            :sponsor_kw  => sponsor_kw,
                                                            :thcn_content_type => thcn_content_type,
                                                            :thcn_super_cat => thcn_super_cat,
                                                            :thcn_category => thcn_category,
                                                            :ugc => "[\"n\"]") 

        ads.validate
        omniture          = @page.omniture
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