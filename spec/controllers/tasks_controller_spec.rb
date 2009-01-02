require File.dirname(__FILE__) + '/../spec_helper'

describe TasksController do
  integrate_views

  it "should get new" do
    get :new
    response.should be_success
  end

  it "should create task" do
    task_params = {
      :title  => "Here's a task", :creator_id => users(:brad).id,
      :status => "prioritized"
    }
    old_count = Task.count
    post :create, :task => task_params
    Task.count.should == old_count + 1
    response.should redirect_to(task_path(assigns(:task)))
  end

  it "should show task" do
    get :show, :id => tasks(:one).id
    response.should be_success
  end

  it "should get edit" do
    get :edit, :id => tasks(:one).id
    response.should be_success
  end

  it "should update task" do
    put :update, :id => tasks(:one).id, :task => { }
    response.should redirect_to(task_path(assigns(:task)))
  end

  it "should destroy task" do
    task = tasks(:one)
    # NOTE [chris]: url_for doesn't work before the request in a functional
    # test.
    request.env["HTTP_REFERER"] = "/users/#{task.assignee_id}"
    old_count = Task.count
    delete :destroy, :id => task.id
    Task.count.should == old_count - 1
    response.should redirect_to(user_path(task.assignee_id))
  end
end
