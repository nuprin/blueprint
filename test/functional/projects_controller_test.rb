require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  def setup
    @controller.stubs(:viewer).returns(users(:one))
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create projects" do
    assert_difference('Project.count') do
      post :create, :project => {:title => "New Project"}
    end
  
    assert_redirected_to project_path(assigns(:project))
  end

  test "should show projects" do
    get :show, :id => projects(:one).id
    assert_response :success
  end

end
