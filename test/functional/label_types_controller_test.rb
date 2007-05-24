require File.dirname(__FILE__) + '/../test_helper'
require 'label_types_controller'

# Re-raise errors caught by the controller.
class LabelTypesController; def rescue_action(e) raise e end; end

class LabelTypesControllerTest < Test::Unit::TestCase
  fixtures :label_types

  def setup
    @controller = LabelTypesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:label_types)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_label_type
    old_count = LabelType.count
    post :create, :label_type => { }
    assert_equal old_count+1, LabelType.count
    
    assert_redirected_to label_type_path(assigns(:label_type))
  end

  def test_should_show_label_type
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_label_type
    put :update, :id => 1, :label_type => { }
    assert_redirected_to label_type_path(assigns(:label_type))
  end
  
  def test_should_destroy_label_type
    old_count = LabelType.count
    delete :destroy, :id => 1
    assert_equal old_count-1, LabelType.count
    
    assert_redirected_to label_types_path
  end
end
