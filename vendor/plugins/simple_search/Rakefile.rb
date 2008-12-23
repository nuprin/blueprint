$KCODE = 'u'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the simple search plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the simple search plugin.'
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'ActiveSearch'
  rdoc.options << '--main=README --line-numbers --inline-source --promiscuous'
  rdoc.rdoc_files.include('README',  'CHANGELOG', 'lib/**/*.rb')
end

desc "Sends the new docs to the server"
task :publish_docs => [:doc] do
  `rsync -arvz ./doc/ julik@julik.nl:~/public_html/code/active-search/`
end

desc "Clear debug log"
task :clear_log do
  `rm test/debug.log`
end