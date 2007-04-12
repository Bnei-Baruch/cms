require File.dirname(__FILE__) + '/../test_helper'
require 'workareas_controller'

# Re-raise errors caught by the controller.
class WorkareasController; def rescue_action(e) raise e end; end

class WorkareasControllerTest < Test::Unit::TestCase
  fixtures :workareas

  def setup
    @controller = WorkareasController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = workareas(:first).id
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

    assert_not_nil assigns(:workareas)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:workarea)
    assert assigns(:workarea).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:workarea)
  end

  def test_create
    num_workareas = Workarea.count

    post :create, :workarea => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_workareas + 1, Workarea.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:workarea)
    assert assigns(:workarea).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Workarea.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Workarea.find(@first_id)
    }
  end
end
