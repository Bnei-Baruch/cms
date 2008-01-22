require File.dirname(__FILE__) + '/../test_helper'
require 'resource_types_controller'

# Re-raise errors caught by the controller.
class ResourceTypesController; def rescue_action(e) raise e end; end

class ResourceTypesControllerTest < Test::Unit::TestCase
  fixtures :resource_types

  def setup
    @controller = ResourceTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:resource_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_resource_type
    old_count = ResourceType.count
    post :create, :resource_type => { }
    assert_equal old_count+1, ResourceType.count
    
    assert_redirected_to admin_resource_type_path(assigns(:resource_type))
  end

  def test_should_show_resource_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_resource_type
    put :update, :id => 1, :resource_type => { }
    assert_redirected_to admin_resource_type_path(assigns(:resource_type))
  end
  
  def test_should_destroy_resource_type
    old_count = ResourceType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ResourceType.count
    
    assert_redirected_to admin_resource_types_path
  end
end
