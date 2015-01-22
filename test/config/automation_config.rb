require 'yaml'

class Configuration
  def self.new name
    @config = nil
    io = File.open( File.dirname(__FILE__) + "/config.yml" )
    YAML::load_documents(io) { |doc| @config = doc[name] }
    raise "Could not locate a configuration named \"#{name}\"" unless @config
    @time = Time.now.strftime("%a-%b-%e-%Y-%k%M").downcase
  end

  def self.[] key
    @config[key]
  end

  def self.[]= key, value
    @config[key] = value
  end

  def self.time
    @time
  end
end

raise "Please set the TEST_ENV environment variable" unless ENV['TEST_ENV']
Configuration.new(ENV['TEST_ENV'])