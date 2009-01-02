require File.dirname(__FILE__) + '/../spec_helper'

describe CompaniesController do
  integrate_views

  it "should get show" do
    get :show
    response.should be_success
  end
end
