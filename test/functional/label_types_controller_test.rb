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

    @first_id = label_types(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:label_types)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:label_type)
    assert assigns(:label_type).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:label_type)
  end

  def test_create
    num_label_types = LabelType.count

    post :create, :label_type => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_label_types + 1, LabelType.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:label_type)
    assert assigns(:label_type).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      LabelType.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      LabelType.find(@first_id)
    }
  end
end
