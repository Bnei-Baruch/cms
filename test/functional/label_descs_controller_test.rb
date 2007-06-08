require File.dirname(__FILE__) + '/../test_helper'
require 'label_descs_controller'

# Re-raise errors caught by the controller.
class LabelDescsController; def rescue_action(e) raise e end; end

class LabelDescsControllerTest < Test::Unit::TestCase
  fixtures :label_descs

  def setup
    @controller = LabelDescsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:label_descs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_label_desc
    old_count = LabelDesc.count
    post :create, :label_desc => { }
    assert_equal old_count+1, LabelDesc.count
    
    assert_redirected_to label_desc_path(assigns(:label_desc))
  end

  def test_should_show_label_desc
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_label_desc
    put :update, :id => 1, :label_desc => { }
    assert_redirected_to label_desc_path(assigns(:label_desc))
  end
  
  def test_should_destroy_label_desc
    old_count = LabelDesc.count
    delete :destroy, :id => 1
    assert_equal old_count-1, LabelDesc.count
    
    assert_redirected_to label_descs_path
  end
end
