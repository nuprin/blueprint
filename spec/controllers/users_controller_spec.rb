require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do
  integrate_views

  it "should get index" do
    get :index
    response.should be_success
  end

  it "should get show" do
    get :show, :id => users(:brad).id
    response.should be_success
  end

  it "should get subscribed" do
    get :subscribed, :id => users(:brad).id
    response.should be_success
  end

  it "should get created" do
    get :created, :id => users(:brad).id
    response.should be_success
  end

  it "should get you" do
    get :you
    response.should redirect_to(user_path(users(:brad)))
  end

end
