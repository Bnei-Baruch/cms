require File.dirname(__FILE__) + '/../test_helper'
require 'label_type_descs_controller'

# Re-raise errors caught by the controller.
class LabelTypeDescsController; def rescue_action(e) raise e end; end

class LabelTypeDescsControllerTest < Test::Unit::TestCase
  fixtures :label_type_descs

  def setup
    @controller = LabelTypeDescsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:label_type_descs)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_label_type_descs
    old_count = LabelTypeDescs.count
    post :create, :label_type_descs => { }
    assert_equal old_count+1, LabelTypeDescs.count
    
    assert_redirected_to label_type_descs_path(assigns(:label_type_descs))
  end

  def test_should_show_label_type_descs
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_label_type_descs
    put :update, :id => 1, :label_type_descs => { }
    assert_redirected_to label_type_descs_path(assigns(:label_type_descs))
  end
  
  def test_should_destroy_label_type_descs
    old_count = LabelTypeDescs.count
    delete :destroy, :id => 1
    assert_equal old_count-1, LabelTypeDescs.count
    
    assert_redirected_to label_type_descs_path
  end
end
