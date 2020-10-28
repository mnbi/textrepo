require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test

desc 'Setup test data'
task :setup_test do
  print "Setting up to execute tests..."
  load('test/fixtures/setup_test_repo.rb', true)
  puts "done."
end

task test: [:setup_test, :clean_sandbox]

require "fileutils"

desc "Clean up test/sandbox"
task :clean_sandbox do
  sandbox = File.expand_path('test/sandbox', __dir__)
  entries = Dir.entries(sandbox).filter_map { |e|
    File.expand_path(e, sandbox) unless e == '.' or e == '..'
  }
  entries.each { |e|
    next if File.basename(e) == '.gitkeep'
    FileUtils.remove_entry_secure(e) if FileTest.exist?(e)
  }
end

task :clobber => :clean_sandbox
CLOBBER << 'test/fixtures/notes'
CLOBBER << 'test/fixtures/test_repo'

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.generator = "ri"
  rdoc.rdoc_dir = "doc"
  rdoc.rdoc_files.include("lib/**/*.rb")
end
