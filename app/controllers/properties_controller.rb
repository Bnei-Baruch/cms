class PropertiesController < ApplicationController
	layout 'admin'

  # GET /properties
  # GET /properties.xml
  def index
    @properties = Property.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @properties.to_xml }
    end
  end
  # GET /properties/1
  # GET /properties/1.xml
  def show
    @property = Property.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @property.to_xml }
    end
  end

  # GET /properties/new
  def new
    @property = Property.new
  end

  # GET /properties/1;edit
  def edit
    @property = Property.find(params[:id])
  end

  # POST /properties
  # POST /properties.xml
  def create
    @property = Property.new(params[:property])

    respond_to do |format|
      if @property.save
        flash[:notice] = 'Property was successfully created.'
        format.html { redirect_to property_url(@property) }
        format.xml  { head :created, :location => property_url(@property) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @property.errors.to_xml }
      end
    end
  end

  # PUT /properties/1
  # PUT /properties/1.xml
  def update
    @property = Property.find(params[:id])

    respond_to do |format|
      if @property.update_attributes(params[:property])
        flash[:notice] = 'Property was successfully updated.'
        format.html { redirect_to property_url(@property) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @property.errors.to_xml }
      end
    end
  end

  # DELETE /properties/1
  # DELETE /properties/1.xml
  def destroy
    @property = Property.find(params[:id])
    @property.destroy

    respond_to do |format|
      format.html { redirect_to properties_url }
      format.xml  { head :ok }
    end
  end
end
