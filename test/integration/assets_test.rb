require_relative '../minitest_helper' 
  
class AssetsTest < MiniTest::Test 
  context "a list of pages" do 
    setup do
      firefox_with_proxy
      @proxy.new_har

      @urls = [
        "#{HC_BASE_URL}/multiple-sclerosis/c/255251/172231/turning-embrace?ic=caro",
        "#{HC_DRUPAL_URL}/adhd/",
        "#{HC_DRUPAL_URL}/skin-care/d/LBLN/living-with-psoriasis/launch/?ic=caro",
        "http://immersive.healthcentral.com/skin-care/d/LBLN/living-with-psoriasis/?ic=caro",
        "#{HC_BASE_URL}/heart-disease/c/all",
        "#{HC_BASE_URL}/heart-disease/c/question",
        "#{HC_BASE_URL}/heart-disease/c/question/230633/173694",
        "#{HC_DRUPAL_URL}/vision-care/d/quizzes/things-every-contact-lens-wearer-should-know"
      ]
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
        if entry.request.url.include?(wrong_asset_host)
          wrong_assets << entry.request.url
        end
        if entry.request.url.include?(ASSET_HOST)
          right_assets << entry.request.url
        end
      end

      assert_equal(true, wrong_assets.compact.empty?)
      assert_equal(false, right_assets.compact.empty?)
    end
  end 
  
  def teardown  
    @driver.quit 
    @proxy.close 
  end  
end 