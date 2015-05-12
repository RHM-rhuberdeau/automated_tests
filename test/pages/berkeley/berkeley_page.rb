require 'active_model'
require_relative './concerns/omniture'
require_relative './concerns/assets'
require_relative './concerns/ads'
require_relative './concerns/slide'
require_relative './concerns/ads_test_cases'
require_relative './concerns/header'
require_relative './concerns/footer'

class BerkeleyPage

  SITE_HOSTS = ["http://qa.berkeleywellness.", "http://qa1.berkeleywellness.","http://qa2.berkeleywellness.","http://qa3.berkeleywellness.", "http://qa4.berkeleywellness.", "http://www.berkeleywellness.", "http://alpha.berkeleywellness.", "http://stage.berkeleywellness."]

  def omniture
    raise NotImplementedError
  end 

  def assets
    raise NotImplementedError
  end

  def global_test_cases
    raise NotImplementedError
  end

  def functionality
    raise NotImplementedError
  end
end