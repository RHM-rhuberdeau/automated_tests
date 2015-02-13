require_relative '../../minitest_helper' 

class BerkleyWellnessTest < MiniTest::Test
  context "Berkley Wellness" do 
    setup do 
      firefox
      visit BW_BASE_URL
    end
   
    should "have 'CUSTOMER SERVICE' in the footer" do 
      links = @driver.find_elements(:css, "footer a")  
      link = links.select { |link| link.text == "CUSTOMER SERVICE"}
      assert(true, link.compact.length == 1)
    end

    should "not have a noindex tag on the homepage" do 
      no_index = @driver.find_elements(:css, "meta[name='robots']")
      assert_equal(true, no_index.empty?, "noindex tag found: #{no_index.inspect}")
    end

 end#context Berkley Wellness

 context "Popular article listing" do 
  setup do 
    firefox
    visit "#{BW_BASE_URL}/popular-article-listing"
  end

  should "have a noindex tag" do 
    no_index = @driver.find_elements(:css, "meta[name='robots']")
    assert_equal(false, no_index.empty?, "noindex tag not found: #{no_index.inspect}")
  end

 end#Popular article listing

  def teardown
    @driver.quit
  end
end