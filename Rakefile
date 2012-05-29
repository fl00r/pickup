#!/usr/bin/env rake
require "bundler/gem_tasks"
require 'rake/testtask'

task :default => :spec

desc 'Tests'
Rake::TestTask.new(:spec) do |t|
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
end