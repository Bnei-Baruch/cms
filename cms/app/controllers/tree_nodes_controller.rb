class TreeNodesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @tree_node_pages, @tree_nodes = paginate :tree_nodes, :per_page => 10
  end

  def show
    @tree_node = TreeNode.find(params[:id])
  end

  def new
    @tree_node = TreeNode.new
  end

  def create
    @tree_node = TreeNode.new(params[:tree_node])
    if @tree_node.save
      flash[:notice] = 'TreeNode was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @tree_node = TreeNode.find(params[:id])
  end

  def update
    @tree_node = TreeNode.find(params[:id])
    if @tree_node.update_attributes(params[:tree_node])
      flash[:notice] = 'TreeNode was successfully updated.'
      redirect_to :action => 'show', :id => @tree_node
    else
      render :action => 'edit'
    end
  end

  def destroy
    TreeNode.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
