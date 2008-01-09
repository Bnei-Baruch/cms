require File.dirname(__FILE__) + '/../test_helper'

class TreeNodesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tree_nodes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_tree_node
    assert_difference('TreeNode.count') do
      post :create, :tree_node => { }
    end

    assert_redirected_to tree_node_path(assigns(:tree_node))
  end

  def test_should_show_tree_node
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_tree_node
    put :update, :id => 1, :tree_node => { }
    assert_redirected_to tree_node_path(assigns(:tree_node))
  end

  def test_should_destroy_tree_node
    assert_difference('TreeNode.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to tree_nodes_path
  end
end
