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

describe TasksController, "a quick added task" do
  before(:each) do
    @old_count = Task.count
    @chris = users(:chris)
    @task = {
      :title => "This is quickly created.",
      :assignee_id => @chris.id,
      :creator_id => users(:brad).id,
      :status => "prioritized",
      :type => "Deliverable"
    }
  end

  it "should require only a name and a creator" do
    post :quick_create, :task => @task
    Task.count.should == @old_count + 1
  end
  
  it "should send an email to the assignee" do
    TaskMailer.expects(:deliver_task_creation).times(1)
    post :quick_create, :task => @task
  end

  it "should not send an email if self assigned" do
    TaskMailer.expects(:deliver_task_creation).times(0)
    post :quick_create,
      :task => @task.merge!(:assignee_id => @task[:creator_id])
  end
end

describe TasksController, "task creation with bad input" do
  before(:each) do
    @task_params = {
      :title  => "This is a task", :creator_id => users(:brad).id,
      :status => "prioritized"
    }
    @old_count = Task.count
  end

  it "should not allow a task to be created without a title" do
    @task_params[:title] = ""
    post :create, :task => @task_params
    Task.count.should == @old_count
    assigns(:task).errors.count.should == 1
  end

  it "should not allow a task to be created with weird estimate " do
    @task_params[:estimate] = "2 hours"
    post :create, :task => @task_params
    Task.count.should == @old_count
    assigns(:task).errors.count.should == 1
  end
end
