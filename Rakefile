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
  ["entries", "questions"].each do |name|
    Rake::TestTask.new("shareposts") do |t|
      t.pattern = "test/integration/healthcentral/#{name}/*.rb"
    end
  end

  desc "Run Shareposts entry tests"
  Rake::TestTask.new("entries") do |t|
    t.pattern = "test/integration/healthcentral/entries/*.rb"
  end

  desc "Run Shareposts question tests"
  Rake::TestTask.new("questions") do |t|
    t.pattern = "test/integration/healthcentral/questions/*.rb"
  end

  desc "Run all keystone tests"
  ["slideshows", "encyclopedia", "daily_dose"].each do |name|
    Rake::TestTask.new("keystone") do |t|
      t.pattern = "test/integration/healthcentral/#{name}/*.rb"
    end
  end

  desc "Run all FDB tests"
  Rake::TestTask.new("fdb") do |t|
    t.pattern = "test/integration/healthcentral/fdb/*.rb"
  end

  desc "Run all encyclopedia tests"
  Rake::TestTask.new("encyclopedia") do |t|
    t.pattern = "test/integration/healthcentral/encyclopedia/*.rb"
  end

  desc "Run all daily dose tests"
  Rake::TestTask.new("daily_dose") do |t|
    t.pattern = "test/integration/healthcentral/daily_dose/*.rb"
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

  desc "Run all concrete five tests"
  Rake::TestTask.new("concrete_five") do |t|
    t.pattern = "test/integration/healthcentral/concrete_five/*.rb"
  end
end

namespace :berkeley do 
  desc "Run all berkeley tests"
  Rake::TestTask.new("all") do |t|
    t.pattern = "test/integration/berkeley_wellness/**/*.rb"
  end

  desc "Run all home page tests"
  Rake::TestTask.new("home_page") do |t|
    t.pattern = "test/integration/berkeley_wellness/home_page/*.rb"
  end

  desc "Run all article tests"
  Rake::TestTask.new("articles") do |t|
    t.pattern = "test/integration/berkeley_wellness/articles/*.rb"
  end

  desc "Run all guides tests"
  Rake::TestTask.new("guides") do |t|
    t.pattern = "test/integration/berkeley_wellness/guides/*.rb"
  end

  desc "Run all guides home tests"
  Rake::TestTask.new("guides_home") do |t|
    t.pattern = "test/integration/berkeley_wellness/guides_home/*.rb"
  end

  desc "Run all slideshow tests"
  Rake::TestTask.new("slideshows") do |t|
    t.pattern = "test/integration/berkeley_wellness/slideshows/*.rb"
  end
end

namespace :the_body do 
  desc "Run all of The Body tests"
  Rake::TestTask.new("all") do |t|
    t.pattern = "test/integration/the_body/**/*.rb"
  end

  desc "Run all articles tests"
  Rake::TestTask.new("articles") do |t|
    t.pattern = "test/integration/the_body/articles/*.rb"
  end

  desc "Run all evp tests"
  Rake::TestTask.new("evp") do |t|
    t.pattern = "test/integration/the_body/evp/*.rb"
  end

  desc "Run all keystone article tests"
  Rake::TestTask.new("keystone_articles") do |t|
    t.pattern = "test/integration/the_body/keystone_articles/*.rb"
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