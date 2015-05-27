require_relative '../../../minitest_helper' 
require_relative '../../../pages/healthcentral/immersive_page'
  
class ImmersivePageTest < MiniTest::Test
  context "an Immersive" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har
    end

    context "living-with-psoriasis" do 
    	setup do
    	  visit "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro"
    	  @page = ::ImmersivePage.new(@driver, @proxy)
    	end

    	should "have an ad at the end of chapter 1" do
        @page.start_immersive
        sleep 5
        sleep 0.5
        @page.show_side_nav
        @page.go_to_chapter(1)
        @page.go_through_chapter
        assert_equal(1, @page.ad_for_chapter('chapter1'))
    	end

    	should "have an ad at the end of chapter 2" do
        @page.start_immersive
        sleep 5
        sleep 0.5
        @page.show_side_nav
        @page.go_to_chapter(2)
        @page.go_through_chapter
        assert_equal(1, @page.ad_for_chapter('chapter2'))
    	end

    	should "have an ad at the end of chapter 3" do
        @page.start_immersive
        sleep 5
        sleep 0.5
        @page.show_side_nav
        @page.go_to_chapter(3)
        @page.go_through_chapter
        assert_equal(1, @page.ad_for_chapter('chapter3'))
    	end

    	should "have an ad at the end of chapter 4" do
    	  @page.start_immersive
    	  sleep 5
        sleep 0.5
        @page.show_side_nav
    	  @page.go_to_chapter(4)
    	  @page.go_through_chapter
    	  assert_equal(1, @page.ad_for_chapter('chapter4'))
    	end
    end#living-with-psoriasis
    context "that is flat" do
      setup do
        visit "http://immersive.healthcentral.com/skin-care/d/LBLN/dtalbert-living-with-psoriasis/flat/"
      end

      should "have chapters" do
        chapter_links = @driver.find_elements(:css, ".chapterPages ul li a").length - 1
        assert_equal(true, chapter_links >= 1)
      end

      should "have an ad on chapter 1" do
        chapter1_link = @driver.find_elements(:css, ".chapterPages ul li a")[1]
        chapter1_link.click
        wait_for_page_to_load
        assert_equal(true, page_has_ad("ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/ps2_chapter1"))
      end

      should "have an ad on chapter 2" do
        chapter1_link = @driver.find_elements(:css, ".chapterPages ul li a")[2]
        chapter1_link.click
        wait_for_page_to_load
        assert_equal(true, page_has_ad("ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/ps2_chapter2"))
      end

      should "have an ad on chapter 3" do
        chapter1_link = @driver.find_elements(:css, ".chapterPages ul li a")[3]
        chapter1_link.click
        wait_for_page_to_load
        assert_equal(true, page_has_ad("ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/ps2_chapter3"))
      end
    end

    context "landing page" do 
      setup do 
        visit "#{HC_BASE_URL}/skin-care/d/immersive/living-psoriasis-diane-talbert"
        @page = ::ImmersivePage.new(@driver, @proxy)
      end
      should "have relatlive links in the header" do 
        links = (@driver.find_elements(:css, ".Page-supercollection-header a") + @driver.find_elements(:css, ".HC-nav-content a") + @driver.find_elements(:css, ".Page-sub-category a")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end

      should "have relative links in the content" do 
        links = (@driver.find_elements(:css, ".Node-content-primary")).collect{|x| x.attribute('href')}.compact
        bad_links = links.map do |link|
          if (link.include?("healthcentral") && link.index(ASSET_HOST) != 0)
            link unless link.include?("twitter")
          end
        end
        assert_equal(true, (bad_links.compact.length == 0), "There were links in the header that did not use relative paths: #{bad_links.compact}")
      end 
    end
  end#an Immersive

  def teardown  
    @driver.quit 
    @proxy.close 
  end 
end