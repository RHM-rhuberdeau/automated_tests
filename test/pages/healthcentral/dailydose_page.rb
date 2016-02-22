require_relative './healthcentral_page'

module DailyDose
  class DailyDosePage < HealthCentralPage
    def initialize(args)
      @driver           = args[:driver]
      @proxy            = args[:proxy]
      @fixture          = args[:fixture]
      @head_navigation  = args[:head_navigation]
      @footer           = args[:footer]
    end

    def functionality(args)
      Functionality.new(:driver => @driver)
    end

    def omniture
      HealthCentralPage.open_omniture_debugger
      omniture_string = HealthCentralPage.get_omniture_from_debugger
      begin
        omniture = Omniture.new(omniture_string: omniture_string, fixture: @fixture)
      rescue Omniture::OmnitureIsBlank
        omniture = OpenStruct.new(:errors => OpenStruct.new(:messages => {:omniture => "Omniture was blank"}), :validate => '')
      end
    end
  end

  class Functionality
    include ::ActiveModel::Validations

    def initialize(args)
      @driver           = args[:driver]
    end
  end

  class Omniture
    class OmnitureIsBlank < Exception; end
    include ::ActiveModel::Validations

    SPECIAL_VALIDATIONS = ['pageName', 'hier1', 'prop5', 'prop10', 'prop12', 'prop13', 'prop22', 'prop38']

    def self.attr_list
      [:pageName, :hier1, :channel, :prop1, :prop2, :prop4, :prop5, :prop6, :prop7, :prop10, :prop12, :prop13, :prop16, :prop17, :prop22, :prop29, :prop30, :prop32, :prop35, :prop37, :prop38, :prop39, :prop40, :prop42, :prop43, :prop44, :prop45, :evar6, :eVar17, :events]
    end

    attr_accessor *attr_list
    validate :values_match_fixture
    validate :correct_report_suite
    validate :prop12_and_13
    validate :pageName_not_blank
    validate :hier1_not_blank
    validate :prop5_not_blank
    validate :prop10_not_blank
    validate :prop38_not_blank
    validate :prop22_not_blank

    def initialize(args)
      @fixture  = args[:fixture]
      raise OmnitureIsBlank unless args[:omniture_string]
      array     = args[:omniture_string]
      start     = array.index { |x| x.include?("pageName") }
      raise OmnitureIsBlank unless start
      range     = array.length - start
      new_array = array[start, range]
      omniture_from_array(new_array)
      get_report_suite(array)
    end

    def get_report_suite(array)
      array.each do |line_of_omniture|
        if line_of_omniture.include?('Report Suite ID(s)')
          @report_suite = line_of_omniture.split(' ').pop.strip
        end
      end
    end

    def omniture_from_array(array_from_omniture_debugger)
      hash = {}
      array_from_omniture_debugger.each do |omniture_line|
        omniture_hash = omniture_line_to_hash(omniture_line)
        if omniture_hash
          hash[omniture_hash.keys.first] = omniture_hash.values.first
        end
      end
      hash.each {|k,v| send("#{k}=",v)}
    end

    def omniture_line_to_hash(omniture_line)
      hash = {}
      Omniture.attr_list.each do |attribute|
        attribute = attribute.to_s
        if omniture_line.include?("#{attribute} ")
          key = omniture_line.slice!(attribute)
          value = omniture_line.strip
          hash = {key => value}
        end
      end
      if hash.empty?
        nil
      else
        hash
      end
    end

    def values_match_fixture
      unless @fixture
        raise 'No fixture for this test'
      end
      Omniture.attr_list.each do |attribute|
        unless SPECIAL_VALIDATIONS.include?(attribute.to_s)
          if @fixture.send(attribute).to_s != self.send(attribute).to_s
            self.errors.add(:omniture, "#{attribute || nil} was #{self.send(attribute)} not #{@fixture.send(attribute)}")
          end
        end
      end
    end

    def correct_report_suite
      unless @report_suite == "cmi-choicemediacom"
        self.errors.add(:omniture, "Omniture report suite being used is: #{@report_suite} not cmi-choicemediacom")
      end
    end

    def prop12_and_13
      unless prop12
        self.errors.add(:omniture, "prop12 was blank")
      end
      unless prop13
        self.errors.add(:omniture, "prop13 was blank")
      end
    end

    def pageName_not_blank
      unless pageName
        self.errors.add(:omniture, "pageName was blank")
      end
      unless pageName && pageName.include?("Verticals > DailyDose > DailyDose")
        self.errors.add(:omniture, "pageName was #{pageName}")
      end
    end

    def hier1_not_blank
      unless hier1
        self.errors.add(:omniture, "hier1 was blank")
      end
      unless hier1 && hier1.include?("Verticals,DailyDose,DailyDose")
        self.errors.add(:omniture, "hier1 was #{hier1}")
      end
    end

    def prop5_not_blank
      unless prop5
        self.errors.add(:omniture, "prop5 was blank")
      end
    end

    def prop10_not_blank
      unless prop10
        self.errors.add(:omniture, "prop10 was blank")
      end
    end

    def prop38_not_blank
      expected_prop38 = @fixture.send(:prop38)
      if expected_prop38
        unless prop38
          self.errors.add(:omniture, "prop38 was blank")
        end
      end
    end

    def prop22_not_blank
      unless prop22.include?("/dailydose/")
        self.errors.add(:omniture, "Prop22 had the wrong value: #{prop22}")
      end
    end
  end
end