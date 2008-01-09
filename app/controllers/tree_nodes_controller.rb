class TreeNodesController < ApplicationController
	layout 'admin'
  # GET /tree_nodes
  # GET /tree_nodes.xml
  def index
  	if params[:parent_id] && params[:parent_id] != '0'
  		@parent_id = params[:parent_id]
  		@parent_node = TreeNode.find(@parent_id)
#  		@grand_parent_id = @parent.parent.id if @parent.parent
		else
			@parent_id = 0
  	end

		@tree_nodes = TreeNode.find(:all,
      :conditions => ["parent_id = ?", @parent_id], :order => "position ASC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tree_nodes }
    end
  end

  # GET /tree_nodes/1
  # GET /tree_nodes/1.xml
  def show
    @tree_node = TreeNode.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tree_node }
    end
  end

  # GET /tree_nodes/new
  # GET /tree_nodes/new.xml
  def new
    @tree_node = TreeNode.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tree_node }
    end
  end

  # GET /tree_nodes/1/edit
  def edit
    @tree_node = TreeNode.find(params[:id])
  end

  # POST /tree_nodes
  # POST /tree_nodes.xml
  def create
    @tree_node = TreeNode.new(params[:tree_node])

    respond_to do |format|
      if @tree_node.save
        flash[:notice] = 'TreeNode was successfully created.'
        format.html { redirect_to(@tree_node) }
        format.xml  { render :xml => @tree_node, :status => :created, :location => @tree_node }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tree_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tree_nodes/1
  # PUT /tree_nodes/1.xml
  def update
    @tree_node = TreeNode.find(params[:id])

    respond_to do |format|
      if @tree_node.update_attributes(params[:tree_node])
        flash[:notice] = 'TreeNode was successfully updated.'
        format.html { redirect_to(@tree_node) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tree_node.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tree_nodes/1
  # DELETE /tree_nodes/1.xml
  def destroy
    @tree_node = TreeNode.find(params[:id])
    @tree_node.destroy

    respond_to do |format|
      format.html { redirect_to(tree_nodes_url) }
      format.xml  { head :ok }
    end
  end
end
