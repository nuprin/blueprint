require File.dirname(__FILE__) + '/test_helper'

class TestIndexerTerm < Test::Unit::TestCase
  load_all_fixtures
  
  def setup
    super
    @page_term_indexer = Page.indexers[1]
    assert_kind_of ActiveSearch::TermIndexer, @page_term_indexer
  end
  
  def test_a_model_setup
    assert defined?(SearchTerm)
    assert SearchTerm.ancestors.include?(ActiveRecord::Base), "A SearchTerm model should have been defined"
    assert SearchTerm.instance_methods.include?('pages'), "An associated collection of Pages should have been rigged"    
    assert SearchTerm.column_names.include?('term'), "A SearchTerm#term method should have been defined"    
    assert Page.reflect_on_association(:search_terms)
    
    puts pages(:first).inspect
    
    assert_equal 2, Page.count, "2 pages should have been loaded from fixtures"
  end
 
   # Terms might be referenced elsewhere so why bother
#  def test_complete_index_cleanup
#    Page.destroy_all
#    assert_equal 0, SearchTerm.count, "All terms had to be cleared because there are no references to them"
#  end
  
  def test_searches

    Page.indexers[1].rebuild!
     # make sure that terms are hooked in
     assert SearchTerm.count > 0
        
     assert_equal 288, SearchTerm.count
     
     assert_kind_of SearchTerm, SearchTerm.find_by_term('brazil')
     assert_kind_of SearchTerm, SearchTerm.find_by_term('casablanca')
     assert_kind_of SearchTerm, SearchTerm.find_by_term('japanese')
     assert_kind_of SearchTerm, SearchTerm.find_by_term('commonterm')
     
     assert_kind_of ActiveSearch::TermIndexer, @page_term_indexer
     
     assert_equal Set.new( [Page.find(1)] ), Set.new(@page_term_indexer.query("brazil"))
       "The first page should be found"
       
     assert_equal Set.new( [Page.find(1)] ), Set.new(@page_term_indexer.query("ministry")),
       "The first page should be found"
       
     assert_equal Set.new( Page.find(:all) ), Set.new(@page_term_indexer.query('commonterm')),
       "All pages should be found"       
      
     assert_equal Set.new( [Page.find(1)] ), Set.new(@page_term_indexer.query("brazil ministry")),
       "Should search on intersection"      

     assert_equal Set.new( [Page.find(1)] ), Set.new(@page_term_indexer.query("ministry commonterm")),
       "The first page should be found - the search is exclusive"

     assert_equal Set.new( [Page.find(2)] ), Set.new(@page_term_indexer.query("japanese")),
       "Related paras should be included in the search"

     assert_equal Set.new( [Page.find(1)] ), Set.new(@page_term_indexer.query("TARKHANOV")),
       "Related authors should be included in the search"  
  end

  def test_scoped_search
    @page_term_indexer.rebuild!
    somep = Page.find(1)
    Page.with_scope( :find => {:conditions => 'page_author_id = 1'} ) do
      assert_equal [somep], @page_term_indexer.query('commonterm')
    end
  end
      
  def test_prune
    @page_term_indexer.rebuild!
    @page_term_indexer.prune!
    assert_equal [], @page_term_indexer.query("japanese")    
  end
  
  def test_delete
    Page.destroy_all
    assert_equal [], @page_term_indexer.query("japanese")
  end
  
  def test_index_updated
    @page_term_indexer.rebuild!
    page = Page.find(1)
    page.page_author = nil
    page.page_paras.clear
    page.body = "The pleasure of the discontent"
    page.save!

    assert_equal [page.id], @page_term_indexer.query("discontent").map(&:id)
  
    [:title, :body, :page_paras].each do | f |
      page[f].respond_to?(:clear) ? page[f].clear : (page[f] = nil)
    end
    page.save!

    assert_equal [], @page_term_indexer.query("discontent")          
    
    @page_term_indexer.rebuild!
  end
end