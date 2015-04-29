# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../config/application', __FILE__)

# Rails.application.load_tasks
task :default => :test

task :test do
  files = Dir[File.join('./test/integration', '**', '*.{rb}')].each do |file| 
    require file      
  end
end

task :healthcentral do 
  files = Dir[File.join('./test/integration/healthcentral/subcategory', '**', '*.{rb}')].each do |file| 
    require file      
  end
end

task :shareposts do 
  files = Dir[File.join('./test/integration/healthcentral/entries', '**', '*.{rb}')] + Dir[File.join('./test/integration/healthcentral/questions', '**', '*.{rb}')]
  files.each do |file|
    require file
  end
end

task :lbln do 
  files = Dir[File.join('./test/integration/healthcentral/lbln', '**', '*.{rb}')].each do |file|
    require file
  end
end

task :quizes do 
  files = Dir[File.join('./test/integration/healthcentral/quiz', '**', '*.{rb}')].each do |file|
    require file
  end
end

task :slideshows do 
  files = Dir[File.join('./test/integration/healthcentral/slideshows', '**', '*.{rb}')].each do |file|
    require file
  end
end

task :subcategory do 
  files = Dir[File.join('./test/integration/healthcentral/subcategory', '**', '*.{rb}')].each do |file|
    require file
  end
end

task :berkley do 
  files = Dir[File.join('./test/integration/berkley_wellness', '**', '*.{rb}')].each do |file| 
    require file      
  end
end

task :the_body do 
  files = Dir[File.join('./test/integration/the_body', '**', '*.{rb}')].each do |file| 
    require file      
  end
end

# require 'rubygems'
# require 'rake/testtask'
# require 'parallel'
# require 'json'

# @browsers = JSON.load(open('browsers.json'))
# @test_folder = "test/*_test.rb"
# @parallel_limit = ENV["nodes"] || 1
# @parallel_limit = @parallel_limit.to_i

# task :minitest do
#   current_browser = ""
#   begin
#     Parallel.map(@browsers, :in_threads => @parallel_limit) do |browser|
#       current_browser = browser
#       puts "Running with: #{browser.inspect}"
#       ENV['SELENIUM_BROWSER'] = browser['browser']
#       ENV['SELENIUM_VERSION'] = browser['browser_version']
#       ENV['BS_AUTOMATE_OS'] = browser['os']
#       ENV['BS_AUTOMATE_OS_VERSION'] = browser['os_version']
#       Dir.glob(@test_folder).each do |test_file|
#         IO.popen("ruby #{test_file}") do |io|
#           io.each do |line|
#             puts line
#           end
#         end
#       end
#     end
#   rescue SystemExit, Interrupt
#     puts "User stopped script!"
#     puts "Failed to run tests for #{current_browser.inspect}"
#   end
# end

# task :default => [:minitest]