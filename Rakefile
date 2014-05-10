# encoding: utf-8

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'yard'
require 'rake/testtask'

# The tests!
Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/**/*_spec.rb']
end

# The beauty!
desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.formatters    = ['progress']
  task.fail_on_error = true
end

# The docs!
YARD::Rake::YardocTask.new(:doc)

task(:default).clear
task default: [:rubocop, :test]
