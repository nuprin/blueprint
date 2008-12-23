require File.dirname(__FILE__) + '/test_helper'
require 'fileutils'

if defined?(ActiveSearch::FerretIndexer)
  puts " ## Will test Ferret as well"

  class TestIndexerFerret < ActiveSupport::TestCase
    load_all_fixtures
 
    def setup
      @indexes_dir = File.dirname(__FILE__) + '/tmp/ferret-indexes'
      FileUtils.rm_rf(@indexes_dir) if File.exist?(@indexes_dir)
    
      assert_nothing_raised do
        Page.indexes_columns :body, :using=>:ferret
        PageAuthor.indexes_columns :bio, :using=>:ferret
      end
    
      @indexer = Page.indexers.last
      @indexer.rebuild!
    end
 
    def teardown
      FileUtils.rm_rf(@indexes_dir) if File.exist?(@indexes_dir)
      ActiveSearch.indexers(Page.to_s).clear
      ActiveSearch.indexers(PageAuthor.to_s).clear
      load File.dirname(__FILE__) + '/fixtures/page.rb'
    end
  
    def test_indexers_on_two_classes_do_not_clash
      author = PageAuthor.create!(:first_name => "Terry", :last_name => "Gilliam", :bio => "Outspoken hero of all times")
      page = Page.create!(:title => "Terry Gilliam", :body => "Outspoken hero of all times")
    
      indexer_for_page = Page.indexers.last
      indexer_for_authors = PageAuthor.indexers.last
    
      found_pages = indexer_for_page.query("outspoken AND hero")
      found_authors = indexer_for_authors.query("outspoken AND hero")
    
      assert_equal 1, found_pages.length
      assert_equal 1, found_authors.length
    end
  
    def test_indexer_setup
      assert File.directory?('/tmp'), "/tmp must be a dir to run this test"
      assert File.writable?('/tmp'), "/tmp must be writable to run this test"    
    
      assert_kind_of ActiveSearch::FerretIndexer, Page.indexers[-1]
      assert_kind_of Ferret::Index::Index, @indexer.ferret_index

      assert_equal 2, @indexer.size, "Indexer#size should be forwarded to Ferret underneath"
    end

    def test_pruning
      assert_equal 2, @indexer.size
      Page.indexers.last.prune!
      assert_equal 0, @indexer.size
    end

    def test_search
      assert_equal 1, @indexer.query('brazil').size
      assert_equal 1, @indexer.query('julian').size
    
      assert_kind_of ActiveSearch::Result, Page.indexers.last.query('brazil').last
    
      assert_equal Page.find(1), @indexer.query('brazil')[0].record
      assert_equal Page.find(2), @indexer.query('veenman')[0].record
    
    
      Object.send(:remove_const, :Page)
      load File.dirname(__FILE__) + '/fixtures/page.rb'
      assert_equal 2, @indexer.query('commonterm').size
      assert_equal 1, @indexer.query('brazil').size
      assert_equal 1, @indexer.query('julian').size
    end

    def test_search_succeeds_even_when_records_gone
      assert_equal 1, @indexer.query('brazil').size
      assert_equal 1, @indexer.query('julian').size
      Page.delete_all
      assert_equal [], @indexer.query('brazil')
    end
  
    def test_result_encapsulates_record_id
      page = Page.find(1)
      page_wrapped = @indexer.query("brazil").first
      assert_equal page.id, page_wrapped.id
    end

    def test_index_updated
      page = Page.find(1)
      page.page_author = nil
      page.page_paras.clear
      page.body = "The pleasure of the discontent"
      page.save!

      assert_equal 1, @indexer.query("discontent").size      
      assert_equal page, @indexer.query("discontent")[0].record      
    end
  end
end