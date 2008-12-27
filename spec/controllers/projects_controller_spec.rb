require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  integrate_views

  it "should get index" do
    get :index
    response.should be_success
    assigns(:projects).should_not be_nil
  end
  
  it "should get new" do
    get :new
    response.should be_success
  end
  
  it "should create projects or some such" do
    old_count = Project.count
    post :create, :project => {:title => "New Project"}
    Project.count.should == old_count + 1
    response.should redirect_to(project_path(assigns(:project)))
  end

  it "should show projects" do
    get :show, :id => projects(:one).id
    response.should be_success
  end  
end
