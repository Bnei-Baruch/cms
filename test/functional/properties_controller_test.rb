require File.dirname(__FILE__) + '/../test_helper'
require 'properties_controller'

# Re-raise errors caught by the controller.
class PropertiesController; def rescue_action(e) raise e end; end

class PropertiesControllerTest < Test::Unit::TestCase
  fixtures :properties

  def setup
    @controller = PropertiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:properties)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_property
    old_count = Property.count
    post :create, :property => { }
    assert_equal old_count+1, Property.count
    
    assert_redirected_to property_path(assigns(:property))
  end

  def test_should_show_property
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_property
    put :update, :id => 1, :property => { }
    assert_redirected_to property_path(assigns(:property))
  end
  
  def test_should_destroy_property
    old_count = Property.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Property.count
    
    assert_redirected_to properties_path
  end
end
