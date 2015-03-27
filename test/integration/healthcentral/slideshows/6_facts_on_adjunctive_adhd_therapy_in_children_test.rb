require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'

class SlideshowTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/adhd/cf/slideshows/6-facts-on-adjunctive-adhd-therapy-in-children"
    end

    should "update the ads between each slide" do 
      @page.go_through_slide_show
      assert_equal(true, @page.has_unique_ads?)
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

    #################################################################
    ################## ASSETS #######################################
    context "assets" do 
      should "have valid assets" do 
        assets = @page.assets
        assets.validate
        assert_equal(true, assets.errors.empty?, "#{assets.errors.messages}")
      end
    end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end