require File.dirname(__FILE__) + '/../spec_helper'

describe SpecificationsController do
  integrate_views

  before(:each) do
    @project_id = projects(:one).id
  end

  it "should get show" do
    get :show, :project_id => @project_id
    response.should be_success
  end
  
  it "should get edit" do
    get :edit, :project_id => @project_id
    response.should be_success
  end
  
  it "should update successfully" do
    put :update, :project_id => @project_id,
      :spec => {:body => "This is well specified"}
    response.should redirect_to(project_specification_path(@project_id))
  end
end
