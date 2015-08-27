require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/berkeley_slide_show_page'

class BerkeleySlideShowTest < MiniTest::Test
  context "can food cause body odor" do 
  	setup do
  	  fire_fox_with_secure_proxy
      @proxy.new_har
      @page = BerkeleySlideshow::SlideshowPage.new(:driver =>@driver, :proxy => @proxy)
      visit "#{BW_BASE_URL}/healthy-eating/food/slideshow/can-food-cause-body-odor"
  	end

  	# should "update slide text while browsing through the slides" do
  	# 	@page.slides.each_with_index do |slide, index|
  	# 	  unless index == (@page.slides.length - 1)
  	# 	  	text = slide.text
   #        @driver.find_element(:css, "a.flex-next").click
   #        wait_for_ajax
   #        assert_equal(false, (text == @page.slideshow.text)) 
  	# 	  end
  	# 	end

   #    slides = @page.slides.to_a.reverse
   #    slides.each_with_index do |slide, index|
   #      unless index == (@page.slides.length - 1)
   #        text = slide.text
   #        @driver.find_element(:css, "a.flex-prev").click
   #        wait_for_ajax
   #        assert_equal(false, (text == @page.slideshow.text)) 
   #      end
   #    end
  	# end

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
    # end

    ##################################################################
    ################### SEO ##########################################
    context "SEO" do 
      should "have valid seo" do 
        seo = @page.seo
        seo.validate
        assert_equal(true, seo.errors.empty?, "#{seo.errors.messages}")
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
  end

  def teardown  
    @driver.quit  
    @proxy.close
  end 
end