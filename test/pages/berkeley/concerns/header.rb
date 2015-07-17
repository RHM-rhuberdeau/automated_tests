class BerkeleyHeader
  class DesktopHeader
    include ::ActiveModel::Validations
    
    def initialize(args)
      @driver = args[:driver]
    end
  end
end