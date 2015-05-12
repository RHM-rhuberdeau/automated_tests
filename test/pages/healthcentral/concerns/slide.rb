module HealthCentralSlide
  class Slide
    attr_reader :text, :ads

    def initialize(args)
      @text = args[:text]
      @ads  = args[:ads]
    end

    def ord_values
      ords = ads.map { |ad| ad.ord }
      ords = ords.uniq!
    end
  end
end