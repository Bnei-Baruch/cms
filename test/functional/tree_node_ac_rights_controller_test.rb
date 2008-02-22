require File.dirname(__FILE__) + '/../test_helper'

class TreeNodeAcRightsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tree_node_ac_rights)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tree_node_ac_rights
    assert_difference('TreeNodeAcRights.count') do
      post :create, :tree_node_ac_rights => { }
    end

    assert_redirected_to tree_node_ac_rights_path(assigns(:tree_node_ac_rights))
  end

  def test_should_show_tree_node_ac_rights
    get :show, :id => tree_node_ac_rights(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => tree_node_ac_rights(:one).id
    assert_response :success
  end

  def test_should_update_tree_node_ac_rights
    put :update, :id => tree_node_ac_rights(:one).id, :tree_node_ac_rights => { }
    assert_redirected_to tree_node_ac_rights_path(assigns(:tree_node_ac_rights))
  end

  def test_should_destroy_tree_node_ac_rights
    assert_difference('TreeNodeAcRights.count', -1) do
      delete :destroy, :id => tree_node_ac_rights(:one).id
    end

    assert_redirected_to tree_node_ac_rights_path
  end
end
