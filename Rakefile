require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require './app'
# task for travis ci
require 'rspec/core/rake_task'
# load all tests in /spec
RSpec::Core::RakeTask.new :specs do |task|
  if ENV['TRAVIS']
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  else
    Rake::Task['db:environment'].invoke
  end
  task.pattern = Dir['spec/**/*_spec.rb']
end

# run tests whenever rake is called
task default: ['specs']
