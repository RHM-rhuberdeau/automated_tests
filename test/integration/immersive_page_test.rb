require_relative '../minitest_helper' 
  
class ImmersivePageTest < MiniTest::Test
  context "living-with-psoriasis" do 
  	setup do
  	  fire_fox_with_secure_proxy
  	  @proxy.new_har
  	  visit "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro"
  	  sleep 1
  	end

  	should "have an ad at the end of chapter 1" do
  	  @driver.find_element(:css, "#edit-submit").click
  	  sleep 5
  	  wait_for_ajax
  	  wait_for_page_to_load
  	  titles = @driver.find_elements(:css, ".chapter-title")
  	  assert_equal(4, titles.length)

  	  @driver.action.move_to(titles[0]).perform
  	  titles[0].click
  	  sleep 2
  	  articles = @driver.find_elements(:css, "article")
  	  16.times do
  	  	@driver.find_element(:css, ".overlay").click
  	  	sleep 2
  	  end

  	  chapter_ads = []
  	  @proxy.har.entries.each do |entry|
  	  	if entry.request.url.include?("http://ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/chapter1")
  	  	  chapter_ads << entry.request.url
  	  	end
  	  end

  	  assert_equal(1, chapter_ads.compact.length)
  	end

  	should "have an ad at the end of chapter 2" do
  	  @driver.find_element(:css, "#edit-submit").click
  	  sleep 5
  	  wait_for_ajax
  	  wait_for_page_to_load
  	  titles = @driver.find_elements(:css, ".chapter-title")

  	  @driver.action.move_to(titles[1]).perform
  	  titles[1].click
  	  sleep 2
  	  articles = @driver.find_elements(:css, "article")
  	  16.times do
  	  	@driver.find_element(:css, ".overlay").click
  	  	sleep 2
  	  end

  	  chapter_ads = []
  	  @proxy.har.entries.each do |entry|
  	  	if entry.request.url.include?("http://ad.doubleclick.net/N3965/adj/cm.ver.lblnskin/immersive/chapter1")
  	  	  chapter_ads << entry.request.url
  	  	end
  	  end

  	  assert_equal(1, chapter_ads.compact.length)
  	end
  end

  def teardown  
    @driver.quit 
    @proxy.close 
  end 
end