class LabelDescsController < ApplicationController

  before_filter :load_label

  # GET /label_descs
  # GET /label_descs.xml
  def index
    @label_descs = @label.label_descs

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @label_descs.to_xml }
    end
  end

  # GET /label_descs/1
  # GET /label_descs/1.xml
  def show
    @label_desc = LabelDesc.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @label_desc.to_xml }
    end
  end

  # GET /label_descs/new
  def new
    @label_desc = @label.label_descs.new
  end

  # GET /label_descs/1;edit
  def edit
    @label_desc = @label.label_descs.find(params[:id])
  end

  # POST /label_descs
  # POST /label_descs.xml
  def create
    @label_desc = @label.label_descs.build(params[:label_desc])

    respond_to do |format|
      if @label_desc.valid? && @label.save!
        flash[:notice] = 'Label Description was successfully created.'
        format.html { redirect_to label_descs_url(@label) }
        format.xml  { head :created, :location => label_descs_url(@label) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @label_desc.errors.to_xml }
      end
    end
  end

  # PUT /label_descs/1
  # PUT /label_descs/1.xml
  def update
    @label_desc = @label.label_descs.find(params[:id])

    respond_to do |format|
      if @label_desc.update_attributes(params[:label_desc])
        flash[:notice] = 'LabelDesc was successfully updated.'
        format.html { redirect_to label_descs_url(@label) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @label_desc.errors.to_xml }
      end
    end
  end

  # DELETE /label_descs/1
  # DELETE /label_descs/1.xml
  def destroy
    @label_desc = LabelDesc.find(params[:id])
    @label_desc.destroy

    respond_to do |format|
      format.html { redirect_to label_descs_url }
      format.xml  { head :ok }
    end
  end

  private

  def load_label
    @label = TextLabel.find(params[:label_id])
    @languages = Language.find(:all).map {|l| [l.label.hrid, l.id]}.sort
  end
end
