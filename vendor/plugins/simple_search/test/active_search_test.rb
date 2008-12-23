require File.dirname(__FILE__) + '/test_helper'

class BogusIndexer < ActiveSearch::Indexer
end

class TestConfiguration < Test::Unit::TestCase
  fixtures *load_all_fixtures

  def setup
    load_fixtures
    @page = Page.find(1)
    @second_page = Page.find(2)
    @author = PageAuthor.find(1)
    @para = PagePara.find(1)
		@ferret = ($WITH_FERRET ? 0 : 1)
  end
  
  def test_records
    assert !Page.find(1).approved?
    assert Page.find(2).approved?
  end
  
  def test_condition
    assert !ActiveSearch::indexers(Page)[2].will_consume?(@page), "This page is not approved?"
    assert ActiveSearch::indexers(Page)[2].will_consume?(@second_page), "This page is approved?"
  end
  
  def test_hash_addressing
    assert_equal 4-@ferret, ActiveSearch::indexers(Page).size
    assert_equal 4-@ferret, ActiveSearch::indexers(:Page).size
    assert_equal 4-@ferret, ActiveSearch::indexers('Page').size
    
    assert_raise(ArgumentError) {
      ActiveSearch::indexers(nil).size
    }
  end
  
  def test_configuration_options  
    assert_equal 4-@ferret, Page.indexers.size    
    assert_equal 1, PageAuthor.indexers.size
    assert_equal 0, PagePara.indexers.size

    assert_equal [:an_index], Page.indexers[0].used_columns
    assert_equal [:search_terms], Page.indexers[1].used_columns
    assert_equal [:an_index, :search_terms, :another_index], ActiveSearch::excluded_attributes_of(Page)
    
    assert_kind_of ActiveSearch::LikeIndexer, Page.indexers[0],
      "A LikeIndexer should have been setup"
      
    assert_equal [:an_index], Page.indexers[0].used_columns
      "an_index should be setup as index column"

    assert_kind_of ActiveSearch::LikeIndexer, PageAuthor.indexers[0],    
      "A LikeIndexer should have been setup"
      
    assert_equal :other_searchable, PageAuthor.indexers[0].index_column_name ,
      "other_searchable should be used as an index"
      
    assert_equal [:page_author, :title, :body, :page_paras, :approved], Page.indexers[0].indexed_columns,
      "Only explicitly specified fields shall be indexed, excluding attributes storing indexes"
    
    assert_equal [:first_name, :last_name, :birth_date, :search_terms], PageAuthor.indexers[0].indexed_columns,
      "Bio and the index column should be excluded from the column list"
    
    assert Page.simply_searchable?
    assert PageAuthor.simply_searchable?
    assert !PagePara.simply_searchable?
    
  end
    
  def test_reindexing
    assert Page.simply_reindex!
    assert PageAuthor.simply_reindex!
  end

	def test_throw_on_empty_term
		for idx in Page.indexers
			assert_raise(ActiveSearch::EmptyTermError) do
				idx.query('')
			end
		end

		assert_raise(ActiveSearch::EmptyTermError) do
			Page.find_using_term('')
		end
	end
end

class TestBasicConfiguration < Test::Unit::TestCase
  load_all_fixtures
  
  def setup
    load_fixtures
    ActiveSearch.indexers(Page.to_s).clear
    ActiveSearch.indexers(PageAuthor.to_s).clear
  end
  
  def teardown
    ActiveSearch.indexers(Page.to_s).clear
    ActiveSearch.indexers(PageAuthor.to_s).clear
    load File.dirname(__FILE__) + '/fixtures/page.rb'
    load File.dirname(__FILE__) + '/fixtures/page_author.rb'
  end
  
  def test_right_response
    assert !Page.simply_searchable?
    assert !PageAuthor.simply_searchable?
  end
  
  def test_bark_on_uknonwn_options
    assert !ActiveSearch::LikeIndexer::DEFAULT_OPTIONS.has_key?(:foo)
    
    assert_raise(ActiveSearch::IndexSetupError) do 
      Page.class_eval do
        indexes_columns :using=>:like, :into=>'an_index', :foo=>'bar'
      end
    end
  end
  
  def test_like_indexer_creation
    assert_raise(ActiveSearch::IndexSetupError, "Should complain that there is no column") do
      Page.class_eval do
        indexes_columns :using=>:like
      end
    end

    assert_nothing_raised do
      Page.class_eval do
        indexes_columns :using=>:like, :into=>'an_index'
      end
    end
    
    assert_equal 1, Page.indexers.length
    assert_kind_of ActiveSearch::LikeIndexer, Page.indexers[0]
  end
  
  def test_term_indexer_creation
    
    assert_raise(ActiveSearch::IndexSetupError, "Should complain that there is no terms table") do
      Page.class_eval do
        indexes_columns :using=>:term, :into=>'some_table'
      end
    end
    assert_nil Page.reflect_on_association(:some_tables)
    
    AddJoin.migrate(:down)

    assert_raise(ActiveSearch::IndexSetupError, "Should complain that there is no join table") do
      PageAuthor.class_eval do
        indexes_columns :using=>:term, :into=>'search_terms'
      end
    end

    AddJoin.migrate(:up)
    
    assert_nothing_raised do
      Page.class_eval do
        indexes_columns :using=>:term, :into=>'search_terms'
      end
    end
    
    assert_kind_of ActiveSearch::TermIndexer, Page.indexers[0]
  end
  
  def test_custom_indexer_creation_using_class
    assert_nothing_raised do 
      Page.class_eval do
        indexes_columns :using=>:term, :using=>BogusIndexer
      end
    end
    
    assert_kind_of BogusIndexer, Page.indexers[0]
  end  

  def test_custom_indexer_creation_using_symbol
    assert_nothing_raised do 
      Page.class_eval do
        indexes_columns :using=>:term, :using=>:bogus
      end
    end
    assert_kind_of BogusIndexer, Page.indexers[0]
  end

	def test_reindex
		Page.simply_reindex!
	end
end