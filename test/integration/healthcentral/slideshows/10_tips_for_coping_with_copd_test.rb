require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'

class SlideshowTest < MiniTest::Test
  context "a drupal slideshow" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
      visit "#{HC_BASE_URL}/copd/cf/slideshows/10-tips-for-coping-with-copd"
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
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end