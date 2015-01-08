require_relative '../minitest_helper' 

class SponsoredTopicTest < MiniTest::Test
  context "a sponsored collection" do 
  	setup do
  	  @collections = CollectionSync.new(COLLECTION_URL)
  	  firefox
  	  visit "http://www.healthcentral.com/rheumatoid-arthritis/m/LBLN/living-with-ra/"
  	end

  	should "be ok" do

  	end
  end
end