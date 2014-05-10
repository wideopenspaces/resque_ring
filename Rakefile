require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.test_files = FileList['spec/**/*_spec.rb']
end

desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['progress']
  # don't abort rake on failure
  task.fail_on_error = false
end
