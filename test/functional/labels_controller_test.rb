require File.dirname(__FILE__) + '/../test_helper'
require 'labels_controller'

# Re-raise errors caught by the controller.
class LabelsController; def rescue_action(e) raise e end; end

class LabelsControllerTest < Test::Unit::TestCase
  fixtures :labels

  def setup
    @controller = LabelsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = labels(:first).id
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

    assert_not_nil assigns(:labels)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:label)
    assert assigns(:label).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:label)
  end

  def test_create
    num_labels = Label.count

    post :create, :label => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_labels + 1, Label.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:label)
    assert assigns(:label).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Label.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Label.find(@first_id)
    }
  end
end
