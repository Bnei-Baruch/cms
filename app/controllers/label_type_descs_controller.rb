class LabelTypeDescsController < ApplicationController

  before_filter :load_data, :except => :destroy

  # GET /label_type_descs
  # GET /label_type_descs.xml
  def index
    @label_type_descs = @label_type.label_type_descs


    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @label_type_descs.to_xml }
    end
  end

  # GET /label_type_descs/new
  def new
    @label_type_desc = @label_type.label_type_descs.new
  end

  # GET /label_type_descs/1;edit
  def edit
    @label_type_desc = @label_type.label_type_descs.find(params[:id])
  end

  # POST /label_type_descs
  # POST /label_type_descs.xml
  def create
    @label_type_desc = @label_type.label_type_descs.build(params[:label_type_desc])

#render :text => @languages.inspect
#return
    respond_to do |format|
      if @label_type_desc.valid? && @label_type.save!
        flash[:notice] = 'LabelTypeDescs was successfully created.'
        format.html { redirect_to label_type_descs_url(@label_type) }
        format.xml  { head :created, :location => label_type_descs_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label_type_desc.errors.to_xml }
      end
    end
  end

  # PUT /label_type_descs/1
  # PUT /label_type_descs/1.xml
  def update
    @label_type_desc = @label_type.label_type_descs.find(params[:id])

    respond_to do |format|
      if @label_type_desc.update_attributes(params[:label_type_desc])
        flash[:notice] = 'LabelTypeDescs was successfully updated.'
        format.html { redirect_to label_type_descs_url(params[:label_type_id]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @label_type_desc.errors.to_xml }
      end
    end
  end

  # DELETE /label_type_descs/1
  # DELETE /label_type_descs/1.xml
  def destroy
    @label_type_desc = LabelTypeDesc.find(params[:id])
    message = "Description (#{@label_type_desc.value}) was successfully destroyed."
    @label_type_desc.destroy

    respond_to do |format|
	    flash[:notice] = message
	    format.html { redirect_to label_type_descs_url(params[:label_type_id]) }
      format.xml  { head :ok }
    end
  end

  private

  def load_data
    @label_type = LabelType.find(params[:label_type_id])
    @languages = Language.find(:all).map {|l| [l.label.hrid, l.id]}.sort
  end

end
