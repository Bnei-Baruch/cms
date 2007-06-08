require File.dirname(__FILE__) + '/../test_helper'
require 'object_types_controller'

# Re-raise errors caught by the controller.
class ObjectTypesController; def rescue_action(e) raise e end; end

class ObjectTypesControllerTest < Test::Unit::TestCase
  fixtures :object_types

  def setup
    @controller = ObjectTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:object_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_object_type
    old_count = ObjectType.count
    post :create, :object_type => { }
    assert_equal old_count+1, ObjectType.count
    
    assert_redirected_to object_type_path(assigns(:object_type))
  end

  def test_should_show_object_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_object_type
    put :update, :id => 1, :object_type => { }
    assert_redirected_to object_type_path(assigns(:object_type))
  end
  
  def test_should_destroy_object_type
    old_count = ObjectType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, ObjectType.count
    
    assert_redirected_to object_types_path
  end
end
