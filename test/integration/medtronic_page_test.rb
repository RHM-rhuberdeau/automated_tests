require_relative '../minitest_helper' 

class MedtronicPageTest< MiniTest::Test
  context "a Medtronic page" do 
  	setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{MED_BASE_URL}/cecs/cf/medtronic"
  	end

    should "not load assets from a wrong host" do
      wrong_assets = []
      right_assets = []

      @proxy.har.entries.find do |entry|
        if entry.request.url.include?(wrong_asset_host)
          wrong_assets << entry.request.url
        end
        if entry.request.url.include?(MED_BASE_URL)
          right_assets << entry.request.url
        end
      end

      assert_equal(true, wrong_assets.compact.empty?, "qa assets were loaded: #{wrong_assets}")
      assert_equal(false, right_assets.compact.empty?, "missing correct assets")
    end

    should "not have unloaded assets" do
      unloaded_assets = []
      unloaded_assets << @proxy.har.entries.find do |entry|
        entry.request.url.split('.com').first.include?(MED_BASE_URL) && entry.response.status != 200
      end

      assert_equal(unloaded_assets.compact.empty?, true)
    end

    should "not have any broken images" do
      all_images = @driver.find_elements(tag_name: 'img')

      broken_images = []
      all_images.each do |img|
        broken_images << @proxy.har.entries.find do |entry|
          entry.request.url == img.attribute('src') && entry.response.status == 404
        end
      end

      assert_equal(true, broken_images.compact.empty?)
    end
  end#a redesigned Shareposts Entry page

  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end