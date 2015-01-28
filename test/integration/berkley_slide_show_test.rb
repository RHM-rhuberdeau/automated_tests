require_relative '../minitest_helper' 
require_relative '../pages/berkley_slide_show_page'

class BerkleySlideShowTest < MiniTest::Test
  context "A Berkley slide show page" do 
  	setup do
  	  fire_fox_with_secure_proxy
      @proxy.new_har
      visit "#{BW_BASE_URL}/healthy-eating/food/slideshow/can-food-cause-body-odor"
      @page = ::BerkleyslideShowPage.new(@driver, @proxy)
  	end

  	should "update slide text while browsing through the slides" do
  		@page.slides.each_with_index do |slide, index|
  		  unless index == (@page.slides.length - 1)
  		  	text = slide.text
          @driver.find_element(:css, "a.flex-next").click
          wait_for_ajax
          assert_equal(false, (text == @page.slideshow.text)) 
  		  end
  		end

      slides = @page.slides.to_a.reverse
      slides.each_with_index do |slide, index|
        unless index == (@page.slides.length - 1)
          text = slide.text
          @driver.find_element(:css, "a.flex-prev").click
          wait_for_ajax
          assert_equal(false, (text == @page.slideshow.text)) 
        end
      end
  	end

    # should "update the ads while browsing through the slides" do
    #   @page.slides.each_with_index do |slide, index|
    #     unless index == (@page.slides.length - 1)
    #       ads_on_last_slide = @page.ads_on_page
    #       @driver.find_element(:css, "a.flex-next").click
    #       wait_for_ajax
    #       sleep 8
    #       assert_equal(false, (ads_on_last_slide == @page.ads_on_page)) 
    #     end
    #   end

    #   #get text from iframe method
    #   # iframe_count = 1
    #   # ads_text_for_slide = {}
    #   # @page.slides.each_with_index do |slide, index|
    #   #   unless index == (@page.slides.length - 1)
    #   #     ads_text_for_slide[index] = @driver.execute_script("return $('iframe').eq(#{iframe_count}).html();")
    #   #     @driver.find_element(:css, "a.flex-next").click
    #   #     wait_for_ajax
    #   #     sleep 5
    #   #     iframe_count += 3
    #   #     new_ads_text = @driver.execute_script("return $('iframe').eq(#{iframe_count}).html();")
    #   #     assert_equal(false, (ads_text_for_slide[index] == new_ads_text)) 
    #   #   end
    #   # end
    # end
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end