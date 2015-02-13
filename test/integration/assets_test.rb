require_relative '../minitest_helper' 
require_relative '../pages/healthcentral_page'
  
class AssetsTest < MiniTest::Test 
  context "A list of pages" do 
    setup do
      fire_fox_with_secure_proxy
      @proxy.new_har

      @urls = [
        "#{HC_BASE_URL}/multiple-sclerosis/c/255251/172231/turning-embrace?ic=caro",
        "#{HC_DRUPAL_URL}/adhd/",
        "#{HC_DRUPAL_URL}/skin-care/d/LBLN/living-with-psoriasis/launch/?ic=caro",
        "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro",
        "#{HC_BASE_URL}/heart-disease/c/all",
        "#{HC_BASE_URL}/heart-disease/c/question",
        "#{HC_BASE_URL}/heart-disease/c/question/230633/173694",
        "#{HC_DRUPAL_URL}/vision-care/d/quizzes/things-every-contact-lens-wearer-should-know",
        "#{HC_DRUPAL_URL}/skin-care/cf/slideshows/7-ways-manage-stress-psoriasis#slide=8",
        "#{HC_DRUPAL_URL}/skin-care/cf/slideshows/top-10-ways-to-live-with-psoriasis",
        "#{HC_DRUPAL_URL}/skin-care/d/quizzes/what-do-you-know-about-psoriasis"
      ]
      @page = ::HealthCentralPage.new(@driver, @proxy)
    end 

    should "not have unloaded assets" do
      @urls.each do |url|
        visit url
      end

      unloaded_assets = []
      unloaded_assets << @proxy.har.entries.find do |entry|
        (entry.request.url.split('.com').first.include?("#{HC_BASE_URL}") || entry.request.url.split('.com').first.include?("#{HC_DRUPAL_URL}") ) && entry.response.status != 200
      end

      assert_equal(unloaded_assets.compact.empty?, true)
    end

    should "not have assets from the wrong environment" do
      @urls.each do |url|
        visit url
      end

      wrong_assets = []
      right_assets = []
      @proxy.har.entries.find do |entry|
        if entry.request.url.include?((["qa.healthcentral.", "qa1.healthcentral","qa2.healthcentral.","qa3.healthcentral.", "www.healthcentral.com", "alpha.healthcentral", "stage.healthcentral."] - [ASSET_HOST]).to_s)
          wrong_assets << entry.request.url
        end
        if entry.request.url.include?(ASSET_HOST)
          right_assets << entry.request.url
        end
      end

      assert_equal(true, wrong_assets.compact.empty?)
      assert_equal(false, right_assets.compact.empty?)
    end

    should "have a correct title" do
      urls = [
       "#{HC_DRUPAL_URL}/skin-care/cf/slideshows/7-ways-manage-stress-psoriasis#slide=8",
        "#{HC_DRUPAL_URL}/skin-care/cf/slideshows/top-10-ways-to-live-with-psoriasis",
        "#{HC_DRUPAL_URL}/skin-care/d/quizzes/what-do-you-know-about-psoriasis",
        "#{HC_BASE_URL}/skin-care/c/1443/163832/10-warning-signs-nail-salon?ic=recc",
        "#{HC_BASE_URL}/ibd/d/living/emotional-impact"
      ]

      bad_titles = urls.map do |url|
        visit url
        if @page.has_correct_title? == false
          url
        end
      end
      assert_equal(true, bad_titles.compact.empty?, "#{bad_titles.compact}")
    end
  end 
  
  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end 