class LabelTypesController < ApplicationController
  # GET /label_types
  # GET /label_types.xml
  def index
    @label_types = LabelType.find(:all, :order => "id ASC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @label_types.to_xml }
    end
  end

  # GET /label_types/1
  # GET /label_types/1.xml
  def show
    @label_type = LabelType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @label_type.to_xml }
    end
  end

  # GET /label_types/new
  def new
    @label_type = LabelType.create(params[:label_type])
  end

  # GET /label_types/1;edit
  def edit
    @label_type = LabelType.find(params[:id])
  end

  # POST /label_types
  # POST /label_types.xml
  def create
#    @label_type = LabelType.new(params[:label_type])
    @label_type = LabelType.create(params[:label_type])
#    @label_type[:type] = params[:label_type][:type_virtual]
#    render :text => @label_type.inspect
#    return
    respond_to do |format|
      if @label_type.save
        flash[:notice] = 'LabelType was successfully created.'
        format.html { redirect_to label_types_url }
        format.xml  { head :created, :location => label_type_url(@label_type) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label_type.errors.to_xml }
      end
    end
  end

  # PUT /label_types/1
  # PUT /label_types/1.xml
  def update
    @label_type = LabelType.find(params[:id])

    respond_to do |format|
      if @label_type.update_attributes(params[:label_type])
        flash[:notice] = 'LabelType was successfully updated.'
        format.html { redirect_to label_types_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @label_type.errors.to_xml }
      end
    end
  end

  # DELETE /label_types/1
  # DELETE /label_types/1.xml
  def destroy
    @label_type = LabelType.find(params[:id])
    @label_type.destroy
    flash[:notice] = 'LabelType was successfully deleted.'
    respond_to do |format|
      format.html { redirect_to label_types_url }
      format.xml  { head :ok }
    end
  end
end
