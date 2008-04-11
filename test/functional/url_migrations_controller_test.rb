require File.dirname(__FILE__) + '/../test_helper'

class UrlMigrationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:url_migrations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_url_migration
    assert_difference('UrlMigration.count') do
      post :create, :url_migration => { }
    end

    assert_redirected_to url_migration_path(assigns(:url_migration))
  end

  def test_should_show_url_migration
    get :show, :id => url_migrations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => url_migrations(:one).id
    assert_response :success
  end

  def test_should_update_url_migration
    put :update, :id => url_migrations(:one).id, :url_migration => { }
    assert_redirected_to url_migration_path(assigns(:url_migration))
  end

  def test_should_destroy_url_migration
    assert_difference('UrlMigration.count', -1) do
      delete :destroy, :id => url_migrations(:one).id
    end

    assert_redirected_to url_migrations_path
  end
end
