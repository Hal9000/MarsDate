require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |task|
  task.libs << 'lib'
  task.test_files = FileList['test/**/*_test.rb', 'test/test.rb']
  task.warning = true
end

task default: :test
