require File.dirname(__FILE__) + '/test_helper'

class TestIndexerLike < ActiveSupport::TestCase
  load_all_fixtures
  
  def test_all_loaded
    assert_equal 2, Page.count
    Page.delete_all
    assert_equal 0, Page.count
  end

  def test_b_afterwards
    assert_equal 2, Page.count
  end
end