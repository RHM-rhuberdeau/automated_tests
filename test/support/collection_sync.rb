#require 'active_support/core_ext/hash/conversions'
require 'httparty'

class CollectionSync 
  attr_reader :url, :feed
  def initialize(url)
  	@url = url
  	@feed = get_feed
  end

  def get_feed
  	response = HTTParty.get(url)
  	if response && (response.code == 200)
  	  response.body
  	end
  end

  def collection
  	collections_hash = Hash.from_xml(feed)
  	collections_hash["collections"]["collection"][0]
  end
end