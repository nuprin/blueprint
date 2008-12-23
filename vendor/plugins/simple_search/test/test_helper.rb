$KCODE = 'u'
$:.unshift(File.dirname(__FILE__) + '/../lib')
$:.reject!{|e| e =~ /mate/i }

require 'test/unit'
require 'fileutils'

require 'rubygems'
require 'active_support'
require 'active_record'
require 'active_record/fixtures'

tempdir = File.join(File.dirname(__FILE__), 'tmp')
Dir.mkdir(tempdir) unless File.directory?(tempdir)
RAILS_ROOT = File.dirname(tempdir + '/../')

require File.dirname(__FILE__)  + "/../init"

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))

db_adapter = ENV['ASEARCH_DB_DRIVER'] ? ENV['ASEARCH_DB_DRIVER'] : 'mysql'
puts "Testing with database driver #{db_adapter}"
puts "Define ASEARCH_DB_DRIVER in your environment to test with another database" unless ENV['ASEARCH_DB_DRIVER'] 

driver = config[db_adapter]
ActiveRecord::Base.establish_connection(driver)
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.logger.level = Logger::DEBUG


require File.dirname(__FILE__) + "/schema"
require File.dirname(__FILE__) + "/002_add_join"
SetupTables.migrate(:up)

$:.unshift File.dirname(__FILE__) + "/fixtures"

require 'page'
require 'page_author'
require 'page_para'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures'


class ActiveSupport::TestCase
  def self.load_all_fixtures
    list = Dir.entries(fixture_path).grep(/\.yml$/i).map{|e| e.gsub(/\.yml$/i, '')}.map(&:to_sym)
    self.fixtures(*list)
  end
end