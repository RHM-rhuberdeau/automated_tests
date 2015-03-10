require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'

class SlideshowTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/multiple-sclerosis/cf/slideshows/top-ten-common-myths-about-ms-busted"
    end

    should "update the ads between each slide" do 
      @page.go_through_slide_show
      assert_equal(true, @page.has_unique_ads?)
    end

    should "not have unloaded assets" do 
      assert_equal(false, @page.has_unloaded_assets?, "#{@page.unloaded_assets}")
    end

    should "load assets from the correct environment" do 
      assert_equal(true, @page.wrong_assets.empty?, "wrong assets: #{@page.wrong_assets}")
      assert_equal(false, @page.right_assets.empty?, "right assets empty: #{@page.right_assets}")
    end

    should "not have any broken images" do
      all_images = @driver.find_elements(tag_name: 'img')

      broken_images = []
      all_images.each do |img|
        broken_images << @proxy.har.entries.find do |entry|
          entry.request.url == img.attribute('src') && entry.response.status == 404
        end
      end

      assert_equal(true, @proxy.har.entries.length >= 1, "no entries in proxy")
      assert_equal(true, broken_images.compact.empty?)
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

    ##################################################################
    ################### ASSETS #######################################
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