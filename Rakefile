# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

# require File.expand_path('../config/application', __FILE__)

# Rails.application.load_tasks
require 'rake/testtask'

task :default => :test

task :test do
  files = Dir[File.join('./test/integration', '**', '*.{rb}')].each do |file| 
    require file      
  end
end

namespace :healthcentral do 
  desc "Run all healthcentral tests"
  Rake::TestTask.new("all") do |t|
    t.pattern = "test/integration/healthcentral/**/*.rb"
  end

  desc "Run all shareposts tests"
  Rake::TestTask.new("shareposts") do |t|
    t.pattern = "test/integration/healthcentral/shareposts/*.rb"
  end

  desc "Run all encyclopedia tests"
  Rake::TestTask.new("encyclopedia") do |t|
    t.pattern = "test/integration/healthcentral/encyclopedia/*.rb"
  end

  desc "Run all phases tests"
  Rake::TestTask.new("phases") do |t|
    t.pattern = "test/integration/healthcentral/phases/*.rb"
  end

  desc "Run all topics tests"
  Rake::TestTask.new("topics") do |t|
    t.pattern = "test/integration/healthcentral/topics/*.rb"
  end

  desc "Run all lbln immersive landing page tests"
  Rake::TestTask.new("lbln") do |t|
    t.pattern = "test/integration/healthcentral/lbln/*.rb"
  end

  desc "Run all mm immersive landing page tests"
  Rake::TestTask.new("mm") do |t|
    t.pattern = "test/integration/healthcentral/mm/*.rb"
  end

  desc "Run all quizes tests"
  Rake::TestTask.new("quizzes") do |t|
    t.pattern = "test/integration/healthcentral/quiz/*.rb"
  end

  desc "Run all slideshow tests"
  Rake::TestTask.new("slideshows") do |t|
    t.pattern = "test/integration/healthcentral/slideshows/*.rb"
  end


  desc "Run all sponsored topics tests"
  Rake::TestTask.new("sponsored_topics") do |t|
    t.pattern = "test/integration/healthcentral/sponsoredtopics/*.rb"
  end


  desc "Run all subcategory tests"
  Rake::TestTask.new("subcategory") do |t|
    t.pattern = "test/integration/healthcentral/subcategory/*.rb"
  end

  desc "Run all clinical trial tests"
  Rake::TestTask.new("clinical_trials") do |t|
    t.pattern = "test/integration/healthcentral/clinical_trials/*.rb"
  end
end

task :berkeley do 
  files = Dir[File.join('./test/integration/berkeley_wellness', '**', '*.{rb}')].each do |file| 
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