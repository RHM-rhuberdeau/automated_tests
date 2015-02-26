require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral_page'
  
class HCSearchTest < MiniTest::Test
  context "a search query" do 
    setup do 
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = ::HealthCentralPage.new(@driver, @proxy)
    end

    should "produce results" do
      visit "#{HC_BASE_URL}"

      element = @driver.find_element(:css, "#q")
      element.send_keys "diabetes"
      button = @driver.find_element(:css, ".icon-search")
      button.click
      wait_for_page_to_load
      assert_equal("Search Results", (@driver.find_element(:css, 'div.page div.body.portal div.content.results h1')).text)
      assert_equal(true, (@driver.find_elements(:css, "div.page div.body.portal div.content.results ul.results li h3 a").length) >= 1)
    end

    should "have unique ads" do 
      visit "#{HC_BASE_URL}/query?q=exercise"

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

    should "have the correct title" do 
      visit "#{HC_BASE_URL}/query?q=exercise"
      assert_equal(true, @page.has_correct_title?, "Page title was: #{@page.driver.title}")
    end

    should "not have unloaded assets" do 
      visit "#{HC_BASE_URL}/query?q=exercise"
      assert_equal(false, @page.has_unloaded_assets?, "#{@page.unloaded_assets}")
    end

    should "load assets from the correct environment" do 
      visit "#{HC_BASE_URL}/query?q=exercise"
      assert_equal(true, @page.wrong_assets.empty?, "wrong assets: #{@page.wrong_assets}")
      assert_equal(false, @page.right_assets.empty?, "right assets empty: #{@page.right_assets}")
    end

    should "not have any broken images" do
      visit "#{HC_BASE_URL}/query?q=exercise"

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


  end#a search query

  def teardown  
    @driver.quit 
  end 
end