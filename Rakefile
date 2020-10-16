require "rake/testtask"

Rake::TestTask.new do |t|
  t.name = 'test:unit'
  t.test_files = FileList['tests/**/*_tests.rb']
  t.verbose = true
  t.warning = false
end

Rake::TestTask.new do |t|
  t.name = 'test:uat:integration'
  t.test_files = FileList['user_acceptance_tests/integration/**/*_tests.rb']
  t.verbose = true
  t.warning = false
end

Rake::TestTask.new do |t|
  t.name = 'test:uat:aws'
  t.test_files = FileList['user_acceptance_tests/aws/**/*_tests.rb']
  t.verbose = true
  t.warning = false
end

Rake::TestTask.new do |t|
  t.name = 'test:uat:azure'
  t.test_files = FileList['user_acceptance_tests/azure/**/*_tests.rb']
  t.verbose = true
  t.warning = false
end

Rake::TestTask.new do |t|
  t.name = 'test:uat:gcp'
  t.test_files = FileList['user_acceptance_tests/gcp/**/*_tests.rb']
  t.verbose = true
  t.warning = false
end

task :unit do
  Rake::Task['test:unit'].invoke
end

desc "Running unit tests"

task default: :unit