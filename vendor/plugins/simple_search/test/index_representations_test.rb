require File.dirname(__FILE__) + '/test_helper'

class TestIndexRepresentations < Test::Unit::TestCase
  load_all_fixtures

  def setup
    load_fixtures
    @page = Page.find(1)
    @author = PageAuthor.find(1)
    @para = PagePara.find(1)
  end
  
  def test_index_representations
    
    assert_equal "mister Julian", @author.index_repr_of_first_name,
      "First name should have an index_repr"
    
    assert_equal "mister julian tarkhanov 03 friday october 2003", @author.index_repr,
      "First name should use index_repr_of_first_name"
    
    assert_equal read_fixture_file("page_para_1_repr"), @para.index_repr

    for page in Page.find(:all)
      elements = page.index_repr.split(/ /)
      assert elements.find{|el| el =~/[^\w]/ }.nil?, "The strings should contain only word characters"
    end

    assert_equal read_fixture_file("page_1_repr_deep"), @page.index_repr_with_associations,
      "The index representation of the page with associations must include the representation of the \
paragraphs"

    assert_equal "something about postmodern cinema and brazil this is a long text written for school", @page.index_repr,
      "The index representation of the page itself must be just the title"
  end
end