class Admin::ResourcesController < ApplicationController
	before_filter :save_refferer_to_session, :only => [ :new, :edit, :destroy ]
  before_filter {|c| c.admin_authorize(['System manager'])}
  
  if AuthenticationModel.current_user_is_admin?
    layout 'admin'
  else
    layout 'not_admin'
  end
  
  
  # GET /resources GET /resources.xml
  def index
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
      format.html # index.rhtml
      format.xml  { render :xml => @resources.to_xml }
      format.js
    end
  end

  # GET /resources/1 GET /resources/1.xml
  def show
    @resource = Resource.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml { render :xml => @resource.to_xml }
    end
  end

  # GET /resources/new
  def new
    @resource_type = ResourceType.find(params[:resource][:resource_type_id])
    @resource = Resource.new(params[:resource])
    @tree_node = TreeNode.new(params[:resource][:tree_node])
  end

  # GET /resources/1;edit
  def edit
    @resource = Resource.find(params[:id])
    @resource_type = @resource.resource_type
    if params[:tree_id]
      @tree_node = TreeNode.find_by_id_and_resource_id(params[:tree_id],params[:id])
    end
  end

  # POST /resources POST /resources.xml
  def create
    @resource_type = ResourceType.find(params[:resource][:resource_type_id])
    @resource = Resource.new(params[:resource])
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
    @resource = Resource.find(params[:id])
    @resource_type = @resource.resource_type
    Website.associate_website(@resource, session[:website])
                    # debugger
    tree_node = params[:resource][:tree_node]
    if tree_node
      @tree_node = TreeNode.find_by_id_and_resource_id(tree_node[:id],params[:id])
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
    @resource.destroy

    respond_to do |format|
      format.html { redirect_to session[:referer] }
      format.xml  { head :ok }
    end
  end

end
