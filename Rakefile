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
  files = Dir[File.join('./test/integration/healthcentral', '**', '*.{rb}')].each do |file| 
      require file      
  end
end