module BerkeleyOmniture
  class Omniture
    include ::ActiveModel::Validations

    def self.attr_list
      [:pageName, :channel, :prop1, :prop2, :prop4, :prop5, :prop6, :prop7, :prop10, :prop12, :prop13, :prop16, :prop17, :prop22, :prop29, :prop30, :prop37, :prop38, :prop39, :prop40, :prop42, :prop43, :prop44, :prop45, :eVar17, :events]
    end

    attr_accessor *attr_list
    validate :values_match_fixture
    validate :correct_report_suite

    def initialize(omniture_string, fixture)
      @fixture  = fixture
      raise OmnitureIsBlank unless omniture_string
      array     = omniture_string.lines
      index     = array.index { |x| x.include?("pageName") }
      raise OmnitureIsBlank unless index
      range     = array.length - index
      new_array = array[index, range]
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
        raise NoOmnitureFixtureError
      end
      Omniture.attr_list.each do |attribute|
        if @fixture.send(attribute).to_s != self.send(attribute).to_s
          self.errors.add(:base, "#{attribute} was #{self.send(attribute)} not #{@fixture.send(attribute)}")
        end
      end
    end

    def correct_report_suite
      if ENV['TEST_ENV'] != 'production'
        suite = "cmi-choicemediacom-berkeley-dev"
      else
        suite = "cmi-choicemediacom-berkeley-prod"
      end
      unless @report_suite == suite
        self.errors.add(:base, "Omniture report suite being used is: #{@report_suite} not #{suite}")
      end
    end
  end
end