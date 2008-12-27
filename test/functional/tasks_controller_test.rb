require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def setup
    @controller.stubs(:viewer).returns(users(:one))
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should create task" do
    task_params = {
      :title  => "Here's a task", :creator_id => users(:one).id,
      :status => "prioritized"
    }
    assert_difference('Task.count') do
      post :create, :task => task_params
    end
  
    assert_redirected_to task_path(assigns(:task))
  end

  test "should show task" do
    get :show, :id => tasks(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => tasks(:one).id
    assert_response :success
  end

  test "should update task" do
    put :update, :id => tasks(:one).id, :task => { }
    assert_redirected_to task_path(assigns(:task))
  end
  
  test "should destroy task" do
    task = tasks(:one)
    @request.env["HTTP_REFERER"] = user_path(task.assignee_id)
    assert_difference('Task.count', -1) do
      delete :destroy, :id => task.id
    end
    assert_redirected_to user_path(task.assignee_id)
  end
end
