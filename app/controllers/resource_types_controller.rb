class ResourceTypesController < ApplicationController
	layout 'admin'

  # GET /resource_types
  # GET /resource_types.xml
  def index
    @resource_types = ResourceType.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @resource_types.to_xml }
    end
  end

  # GET /resource_types/1
  # GET /resource_types/1.xml
  def show
    @resource_type = ResourceType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @resource_type.to_xml }
    end
  end

  # GET /resource_types/new
  def new
    @resource_type = ResourceType.new
  end

  # GET /resource_types/1;edit
  def edit
    @resource_type = ResourceType.find(params[:id])
  end

  # POST /resource_types
  # POST /resource_types.xml
  def create
    @resource_type = ResourceType.new(params[:resource_type])

    respond_to do |format|
      if @resource_type.save
        flash[:notice] = 'ResourceType was successfully created.'
        format.html { redirect_to resource_type_url(@resource_type) }
        format.xml  { head :created, :location => resource_type_url(@resource_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @resource_type.errors.to_xml }
      end
    end
  end

  # PUT /resource_types/1
  # PUT /resource_types/1.xml
  def update
    @resource_type = ResourceType.find(params[:id])

    respond_to do |format|
      if @resource_type.update_attributes(params[:resource_type])
        flash[:notice] = 'ResourceType was successfully updated.'
        format.html { redirect_to resource_type_url(@resource_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @resource_type.errors.to_xml }
      end
    end
  end

  # DELETE /resource_types/1
  # DELETE /resource_types/1.xml
  def destroy
    @resource_type = ResourceType.find(params[:id])
    @resource_type.destroy

    respond_to do |format|
      format.html { redirect_to resource_types_url }
      format.xml  { head :ok }
    end
  end
end
