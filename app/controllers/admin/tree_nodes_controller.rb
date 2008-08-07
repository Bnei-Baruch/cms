class Admin::TreeNodesController < ApplicationController
  layout 'admin'

  cache_sweeper :cms_sweeper, :only => [:create, :update, :destroy]

  before_filter :save_refferer_to_session, :only => [ :new, :edit, :destroy, :tree_node_ac_rights, :tree_node_delete ]
  before_filter {|controller| 
    unless ['destroy', 'tree_node_delete'].include?(controller.action_name)
      controller.admin_authorize(['System manager'])
    end
  }
  
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
    #if (@tree_node = TreeNode.find(params[:id]))==undefined
    #  @tree_node = TreeNode.find(0)
    #end

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
  
  #GET 
  def tree_node_ac_rights
    #check if current user has access to see permission list
    admin_authorize(['Nodes Access Rights'])
    #load  permission rights list
    @tree_node_ac_rights = TreeNodeAcRight.find(:all, :conditions => ["tree_node_id = ?", params[:id]])
  end
  
  # GET /tree_nodes/1/tree_node_delete
  def tree_node_delete
    success_flag = true
    @tree_node = TreeNode.find(params[:id])
    
    if @tree_node.nil?
        flash[:notice] = "Tree node does not exist " + params[:id]
        logger.error("Tree node does not exist " + params[:id])
        return
    end
    
    #   ******************
    #   Check permissions!
    if not (@tree_node.can_delete?)
      flash[:notice] = "Access denied. User can't delete tree node"
      logger.error("User #{AuthenticationModel.current_user} has no permission " + 
          "to edit tree_node: #{@tree_node.id} resource: #{@tree_node.resource_id}")
      return
    end
    #   ******************

    if success_flag
      if @tree_node.logical_delete
          flash[:notice] = 'Resource was successfully deleted.'
      else
          success_flag = false
          flash[:notice] = 'Resource was fail on delete.'
          logger.error("Resource was fail on delete.")
      end
    end
    
    if not success_flag
      return
    end
    
    respond_to do |format|
      format.html {
        if request.xhr?
            head(:ok).to_json
          return
        end
        redirect_to session[:referer] 
        
      }
      format.xml  { head :ok }
      format.json { head(:ok).to_json}
    end
    return
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
    #   ******************
    #   Check permissions!
    if not (@tree_node && @tree_node.can_administrate?)
      flash[:notice] = "Access denied. User can't delete tree node"
      redirect_to session[:referer]
    end
    #   ******************

    @tree_node.destroy

    respond_to do |format|
      format.html { redirect_to session[:referer] }
      format.xml  { head :ok }
      format.json { head(:ok).to_json}
    end
  end
  
  def ext_old  (id = params[:node])
    @tree_nodes = TreeNode.find_children(id)
    @new_tree_nodes = Array.new
    
    @tree_nodes.each do |element|
      @new_tree_nodes << Hash["id" => element.id, "text" => element.resource.name, "leaf" => element.leaf]
    end
    
    respond_to do |format|
      format.html  # render { static index.html.erb }
      format.json { render :json => @new_tree_nodes.to_json }
    end
  end
  
  def ext  (id = params[:node])
    @tree_nodes = TreeNode.find_children(id)
    @new_tree_nodes = Array.new
    
    @tree_nodes.each do |element|
      @new_tree_nodes << Hash["id" => element.id,
        "text" => element.resource.name,
        "status" => element.resource.status,
        "type" => element.resource.resource_type.name,
        "permalink" => element.permalink,
        "parentId" => id,
        "ismain" => element.is_main,
        "canEdit" => !element.can_edit?,
        "canDelete" => !element.can_administrate?,
        "canAdd" => !element.can_create_child?,
        #"addTarget" => new_admin_resource_path,
        "delTarget" => admin_resource_path(element.resource),
        "editTarget" => url_for(edit_admin_resource_path(:id => element.resource, :tree_id => element.id)),
        "permissionsTarget" => url_for(admin_tree_node_tree_node_permissions_path(element.id)),
        "leaf" => element.leaf]
    end
    
    respond_to do |format|
      format.html  # render { static index.html.erb }
      format.json { render :json => @new_tree_nodes.to_json }
    end
  end
end
