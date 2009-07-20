# Bwaha... stole much of this from the Merb Rakefile

require "rake"
require "rake/clean"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"
require "spec/rake/spectask"
require "fileutils"
 
def __DIR__
  File.dirname(__FILE__)
end 
include FileUtils

NAME = "bricklayer"
 
 require "lib/bricklayer/version"

 require "lib/bricklayer/test/run_specs"

##############################################################################
# Packaging & Installation
##############################################################################
CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache"]
 
windows = (PLATFORM =~ /win32|cygwin/) rescue nil
 
SUDO = windows ? "" : "sudo"
 
task :bricklayer => [:clean, :rdoc, :package]
 
spec = Gem::Specification.new do |s|
  s.name         = NAME
  s.version      = Bricklayer::VERSION
  s.platform     = Gem::Platform::RUBY
  s.author       = "Mason Browne"
  s.email        = "mason.browne@gmail.com"
  s.homepage     = "http://heypanda.com"
  s.summary      = "Bricklayer. RESTful API client builder for Ruby developers on the go."
  s.bindir       = "bin"
  s.description  = s.summary
  s.executables  = []
  s.require_path = "lib"
  s.files        = %w( LICENSE README Rakefile ) + Dir["{docs,bin,spec,lib,examples,script}/**/*"]
 
  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w( README LICENSE )
  #s.rdoc_options     += RDOC_OPTS + ["--exclude", "^(app|uploads)"]
 
  # Dependencies
  
  # Requirements
  #s.requirements << "install the json gem to get faster json parsing"
  s.required_ruby_version = ">= 1.8.4"
end
 
Rake::GemPackageTask.new(spec) do |package|
  package.gem_spec = spec
end
 
desc "Run :package and install the resulting .gem"
task :install => :package do
  sh %{#{SUDO} gem install --local pkg/#{NAME}-#{Bricklayer::VERSION}.gem --no-rdoc --no-ri}
end

def setup_specs(name, spec_cmd='spec', run_opts = "-c -f s")
  desc "Run all specs (#{name})"
  task "specs:#{name}" do
    run_specs("spec/**/*_spec.rb", spec_cmd, ENV['RSPEC_OPTS'] || run_opts)
  end
end
 
setup_specs("mri", "spec")

task :default => "specs:mri"