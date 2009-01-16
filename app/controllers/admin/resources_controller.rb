class Admin::ResourcesController < ApplicationController
  before_filter :save_refferer_to_session, :only => [ :new, :edit, :destroy ]
  
  cache_sweeper :cms_sweeper, :only => [:create, :update, :destroy]

  # This block sets layout for admin user and for all other.
  layout :set_layout
  def set_layout
    if AuthenticationModel.current_user_is_admin?
      'admin'
    else
      'not_admin'
    end
  end

  # GET /resources GET /resources.xml
  def index
    admin_authorize(['System manager'])
    
    #     	update the website session information if the request is xhr
    if request.xhr?
      set_website_session(params[:show_all_websites])
    end
    website_id = session[:website]
    if website_id && (website = Website.find_by_id(website_id))
      @resources = website.resources.uniq
    else
      @resources = Resource.find(:all)
    end
    @resources.sort! { |a, b| b.id <=> a.id }

    respond_to do |format|
      format.html #{render :action => index, :layout => @layout}
      format.xml  { render :xml => @resources.to_xml }
      format.js
    end
  end

  # GET /resources/1 GET /resources/1.xml
  # def show
  #   @resource = Resource.find(params[:id])
  # 
  #   respond_to do |format|
  #     format.html #{render :action => show, :layout => @layout}# show.rhtml
  #     format.xml { render :xml => @resource.to_xml }
  #   end
  # end

  # GET /resources/new
  def new
    @resource_type = ResourceType.find(params[:resource][:resource_type_id])
    @resource = Resource.new(params[:resource])
    
    #   ******************
    #   Check permissions!
    #    parent_tree_node = TreeNode.find(params[:resource][:tree_node][:parent_id])
    #    if not (parent_tree_node && parent_tree_node.can_create_child?)
    #      flash[:notice] = "Access denied. User can't create tree node"
    #      redirect_to session[:referer]
    #    end
    #   ******************
    parent_id = params[:resource][:tree_node][:parent_id]
    unless parent_id == '0' && AuthenticationModel.current_user_is_admin?
      parent_tree_node = TreeNode.find(parent_id)
      if not (parent_tree_node && parent_tree_node.can_create_child?)
        flash[:notice] = "Access denied. User can't create tree node"
        redirect_to session[:referer]
      end
    end
    
  
    @tree_node = TreeNode.new(params[:resource][:tree_node])
  end

  # GET /resources/1;edit
  def edit
    @resource = Resource.find(params[:id])
    @resource_type = @resource.resource_type
    if params[:tree_id]
      @tree_node = TreeNode.find_by_id_and_resource_id(params[:tree_id],params[:id])
    end

    #   ******************
    #   Check permissions!
    if not (@tree_node && @tree_node.can_edit?)
      flash[:notice] = "Access denied. User can't edit this node"
      redirect_to session[:referer]
    end
    #   ******************
    
  end

  # POST /resources POST /resources.xml
  def create
    # Draft or Publish buttons support

    params[:resource][:status] = 'PUBLISHED' if params[:publish_button]
    params[:resource][:status] = 'DRAFT' if params[:draft_button]
    params[:resource][:status] = 'ARCHIVED' if params[:archive_button]

    @resource_type = ResourceType.find(params[:resource][:resource_type_id])
    @resource = Resource.new(params[:resource])

    #   ******************
    #   Check permissions!
    #    parent_tree_node = TreeNode.find(params[:resource][:tree_node][:parent_id])
    #    if not (parent_tree_node && parent_tree_node.can_create_child?)
    #      flash[:notice] = "Access denied. User can't create tree node"
    #      redirect_to session[:referer]
    #    end
    #   ******************
    
    parent_id = params[:resource][:tree_node][:parent_id]
    unless parent_id == '0' && AuthenticationModel.current_user_is_admin?
      parent_tree_node = TreeNode.find(parent_id)
      if not (parent_tree_node && parent_tree_node.can_create_child?)
        flash[:notice] = "Access denied. User can't create tree node"
        redirect_to session[:referer]
        return
      end
    end

    @tree_node = TreeNode.new(params[:resource][:tree_node])
    Website.associate_website(@resource, session[:website])

    respond_to do |format|
      if @resource.save
        flash[:notice] = 'Resource was successfully created.'
        format.html { redirect_to session[:referer]}
        format.xml  { head :created, :location => admin_resource_url(@resource) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource.errors.to_xml }
      end
    end
  end

  # PUT /resources/1 PUT /resources/1.xml
  def update
    # Draft or Publish buttons support
    params[:resource][:status] = 'PUBLISHED' if params[:publish_button]
    params[:resource][:status] = 'DRAFT' if params[:draft_button]
    params[:resource][:status] = 'ARCHIVED' if params[:archive_button]

    @resource = Resource.find(params[:id])
    @resource_type = @resource.resource_type
    Website.associate_website(@resource, session[:website])
    tree_node = params[:resource][:tree_node]
    if tree_node
      @tree_node = TreeNode.find_by_id_and_resource_id(tree_node[:id],params[:id])
    end

    #    #   ******************
    #    #   Check permissions!
    #    if not (@tree_node && @tree_node.can_edit?)
    #      flash[:notice] = "Access denied. User can't edit this node"
    #      redirect_to session[:referer]
    #    end
    #    #   ******************

    parent_id = params[:resource][:tree_node][:parent_id]
    unless parent_id == '0' && AuthenticationModel.current_user_is_admin?
      parent_tree_node = TreeNode.find(parent_id)
      if not (@tree_node && @tree_node.can_edit?)
        flash[:notice] = "Access denied. User can't create tree node"
        redirect_to session[:referer]
      end
    end

    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource was successfully updated.'
        format.html { redirect_to session[:referer] }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" } #:text => params.inspect } #  }
        format.xml  { render :xml => @resource.errors.to_xml }
      end
    end
  end

  # DELETE /resources/1 DELETE /resources/1.xml
  def destroy
    @resource = Resource.find(params[:id])

    #    #   ******************
    #    #   Check permissions!
    #    main_tree_node = @resource.tree_nodes.select{ |e| e.is_main == true }.first
    #    if not (main_tree_node && main_tree_node.can_administrate?)
    #      flash[:notice] = "Access denied. User can't delete tree node"
    #      redirect_to session[:referer]
    #    end
    #    #   ******************

    @resource.destroy
    respond_to do |format|
      format.html { redirect_to session[:referer] }
      format.xml  { head :ok }
    end
  end
 
end
