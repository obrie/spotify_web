require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Default: run all specs.'
task :default => :spec

load File.dirname(__FILE__) + '/lib/tasks/spotify_web.rake'