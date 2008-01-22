class Admin::ResourceTypesController < ApplicationController
	layout 'admin'

  # GET /resource_types GET /resource_types.xml
  def index
		if request.xhr?
			set_website_session(params[:show_all_websites])
		end
		website_id = session[:website] 
		if website_id && (website =	Website.find_by_id(website_id, :order => 'name'))
			@resource_types = website.resource_types.uniq
		else
			@resource_types = ResourceType.find(:all, :order => 'name')
		end
		respond_to do |format|
			format.html # index.rhtml
			format.xml  { render :xml => @resource_types.to_xml }
			format.js
		end
	end

  # GET /resource_types/1 GET /resource_types/1.xml
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

  # POST /resource_types POST /resource_types.xml
	def create
		@resource_type = ResourceType.new(params[:resource_type])
		Website.associate_website(@resource_type, session[:website])

		respond_to do |format|
			if @resource_type.save
				flash[:notice] = 'ResourceType was successfully created.'
				format.html { redirect_to resource_types_url }
				format.xml  { head :created, :location => resource_types_url }
			else
				format.html { render :action => "new" }
				format.xml  { render :xml => @resource_type.errors.to_xml }
			end
		end
	end

  # PUT /resource_types/1 PUT /resource_types/1.xml
	def update(source = nil)
		@resource_type = ResourceType.find(params[:id])
		Website.associate_website(@resource_type, session[:website])

		respond_to do |format|
			if @resource_type.update_attributes(params[:resource_type])
				flash[:notice] = 'ResourceType was successfully updated.'
				format.html { redirect_to resource_types_url }
				format.xml  { head :ok }
			else
				format.html { redirect_to :back }
				if source == 'associations' 
					format.html { render :action => "associations_list" }
				else
					format.html { render :action => "edit" }
				end
				format.xml  { render :xml => @resource_type.errors.to_xml }
			end
		end
	end
	
	def associations_list
		@resource_type = ResourceType.find(params[:id])
	end
	
	def associations_update
		update('associations')
	end
	
  # DELETE /resource_types/1 DELETE /resource_types/1.xml
	def destroy
		@resource_type = ResourceType.find(params[:id])
		@resource_type.destroy

		respond_to do |format|
			format.html { redirect_to resource_types_url }
			format.xml  { head :ok }
		end
	end
  
  def sort_properties
    list = params[:property_fields].each_with_index {|rt_property_id, index|
      elem = ResourceTypeProperty.find(rt_property_id)
      index += 1
      if elem.position != index
        elem.update_attributes(:position => index)
      end
    }
		render :nothing => true
  end
end
