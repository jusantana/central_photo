require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './app'
#task for travis ci
require 'rspec/core/rake_task'
#load all tests in /spec
RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['spec/**/*_spec.rb']
end

#run tests whenever rake is called
task :default => ['specs']
