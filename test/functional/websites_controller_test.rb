require File.dirname(__FILE__) + '/../test_helper'
require 'websites_controller'

# Re-raise errors caught by the controller.
class WebsitesController; def rescue_action(e) raise e end; end

class WebsitesControllerTest < Test::Unit::TestCase
  fixtures :websites

  def setup
    @controller = WebsitesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:websites)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_website
    old_count = Website.count
    post :create, :website => { }
    assert_equal old_count+1, Website.count
    
    assert_redirected_to website_path(assigns(:website))
  end

  def test_should_show_website
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_website
    put :update, :id => 1, :website => { }
    assert_redirected_to website_path(assigns(:website))
  end
  
  def test_should_destroy_website
    old_count = Website.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Website.count
    
    assert_redirected_to websites_path
  end
end
