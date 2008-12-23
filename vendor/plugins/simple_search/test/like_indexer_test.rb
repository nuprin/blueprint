require File.dirname(__FILE__) + '/test_helper'

class TestIndexerLike < Test::Unit::TestCase
  load_all_fixtures

  def setup
    load_fixtures
    
    Page.indexers[0].rebuild!
    Page.indexers[2].rebuild!
    PageAuthor.indexers[0].rebuild!
    
    @page_like_indexer = Page.indexers[0]
    @page_like_indexer_with_conditional = Page.indexers[2]
    @page_author_like_indexer = PageAuthor.indexers[0]
    @unapproved_page = Page.find(1)
    @approved_page = Page.find(2)
  end

  def test_indexers_properly_setup
    assert_kind_of ActiveSearch::LikeIndexer, @page_like_indexer
    assert_kind_of ActiveSearch::LikeIndexer, @page_author_like_indexer
    assert_kind_of ActiveSearch::LikeIndexer, @page_like_indexer_with_conditional
  end
    
  def test_like_indexer_with_conditional
    assert_equal :approved?, @page_like_indexer_with_conditional.creation_options[:if]
    assert @page_like_indexer_with_conditional.will_consume?(@approved_page)
    assert !@page_like_indexer_with_conditional.will_consume?(@unapproved_page)
    
    Page.find(:all).map do |  p |
      assert p.another_index.blank?, "The unapproved page should have its another_index empty" unless p.approved?
    end
    
    assert_equal [Page.find(2)], @page_like_indexer_with_conditional.query("something"),
      "Only the page that was 'Approved' should have been indexed"
  end
  
  def test_like_indexer_with_conditional_deletes_entries_when_records_marked_unapproved
    Page.find(:all).each{|p| p.approved = false; p.save; p.reload
      assert p.another_index.blank?,
        "The index of the page marked unapproved should have been set to blank by the indexer"
    }
    assert_equal [], @page_like_indexer_with_conditional.query("something")
  end
  
  def test_result_encapsulates_record_id
    page = Page.find(1)
    page_wrapped = @page_like_indexer.query("brazil").first
    assert_equal page.id, page_wrapped.id
  end
  
  def test_searches_with_like_indexer
    
    assert @page_like_indexer.creation_options[:if], "The automatic :if option value is true"
    
    assert_equal [Page.find(1)], @page_like_indexer.query("brazil")
      "The first page should be found"

    assert_equal [Page.find(2)], @page_like_indexer.query("japanese"),
      "Related paras should be included in the search"
    
    assert_equal [Page.find(2)], @page_like_indexer.query("veenman"),
      "Related authors should be included in the search"

    assert_equal [Page.find(2)], @page_like_indexer.query("approved"),
      "Record that is 'Approved' should be found by predicate"

    assert_equal [PageAuthor.find(1)], @page_author_like_indexer.query("JuliAn"),
      "Searches should be case-insensitive"
      
    assert_equal [PageAuthor.find(1)], @page_author_like_indexer.query("Julian Tarkhanov"),
      "Author should be included in the index"

    assert_equal [PageAuthor.find(2)], @page_author_like_indexer.query("Tuesday"),
      "Record that was modified on Tuesday should be found"

  end
  
  def test_create
    @page = Page.create!(:page_author_id => 1,
        :title => "Welcome to Honduras",
        :body => "Honduras is a beautiful country")
    
    assert_equal [@page], @page_like_indexer.query("honduras")
    
    @page_two = Page.create(:page_author_id => 1,
        :title => "Welcome to Guiane",
        :body => "Guiane has malaria",
        :approved => false)
        
    assert_equal [@page], @page_like_indexer.query("honduras")
    assert_equal [@page_two], @page_like_indexer.query("guiane")
    assert @page_two.another_index.blank?, "The columns used by the cond.indexerr should have been left blank"
    assert_equal [], @page_like_indexer_with_conditional.query("guiane"), "This page was marked as disapproved so..."
  end

  def test_scoped_search
    assert_equal 2, @page_like_indexer.query('commonterm').size
    
    Page.with_scope(:find => {:conditions => 'page_author_id = 1'}) do
      found_pages = @page_like_indexer.query('commonterm')
      assert_equal 1, found_pages.length
      assert_equal [Page.find(1)], found_pages
    end
  end
  
  def test_pruning
    @page_like_indexer.prune!
    assert_equal [], @page_author_like_indexer.query("japanese")    
  end
  
  def test_delete
    Page.destroy_all
    assert_equal [], @page_author_like_indexer.query("galaxy")
  end
  
  def test_index_updated
    page = Page.find(1)
    page.page_author = nil
    page.page_paras.clear
    page.body = "The pleasure of the discontent"
    page.save!

    assert_equal [], @page_like_indexer.query("galaxy")    
    assert_equal [page], @page_like_indexer.query("discontent")      
  end
end