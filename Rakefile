require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/**/*_spec.rb']
end

desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.formatters    = ['progress']
  task.fail_on_error = true
end

task(:default).clear
task default: [:rubocop, :test]
