require File.dirname(__FILE__) + '/../test_helper'
require 'languages_controller'

# Re-raise errors caught by the controller.
class LanguagesController; def rescue_action(e) raise e end; end

class LanguagesControllerTest < Test::Unit::TestCase
  fixtures :languages

  def setup
    @controller = LanguagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:languages)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_language
    old_count = Language.count
    post :create, :language => { }
    assert_equal old_count+1, Language.count
    
    assert_redirected_to language_path(assigns(:language))
  end

  def test_should_show_language
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_language
    put :update, :id => 1, :language => { }
    assert_redirected_to language_path(assigns(:language))
  end
  
  def test_should_destroy_language
    old_count = Language.count
    delete :destroy, :id => 1
    assert_equal old_count-1, Language.count
    
    assert_redirected_to languages_path
  end
end
