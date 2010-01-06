require 'test_helper'

class IncidentsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:incidents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create incident" do
    assert_difference('Incident.count') do
      post :create, :incident => { }
    end

    assert_redirected_to incident_path(assigns(:incident))
  end

  test "should show incident" do
    get :show, :id => incidents(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => incidents(:one).id
    assert_response :success
  end

  test "should update incident" do
    put :update, :id => incidents(:one).id, :incident => { }
    assert_redirected_to incident_path(assigns(:incident))
  end

  test "should destroy incident" do
    assert_difference('Incident.count', -1) do
      delete :destroy, :id => incidents(:one).id
    end

    assert_redirected_to incidents_path
  end
end
