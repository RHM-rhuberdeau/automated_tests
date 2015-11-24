require_relative '../../../minitest_helper' 
require_relative '../../../pages/berkeley/berkeley_slide_show_page'

class BerkeleyFlatSlideshowTest < MiniTest::Test
  context "slide 1578" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
      @page = BerkeleySlideshow::SlideshowPage.new(:driver =>@driver, :proxy => @proxy)
      @url  = "#{BW_BASE_URL}/healthy-eating/food-safety/lists/food-poisoning-facts/slideid_1578" + $_cache_buster
      visit @url
    end

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
    cleanup_driver_and_proxy
  end 
end