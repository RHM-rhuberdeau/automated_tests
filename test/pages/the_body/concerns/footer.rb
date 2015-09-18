module TheBodyFooter
  class RedesignFooter
    include ::ActiveModel::Validations
    
    def initialize(args)
      @driver = args[:driver]
    end
  end
end