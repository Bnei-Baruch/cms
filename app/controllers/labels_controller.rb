class LabelsController < ApplicationController
  # GET label_types/1/labels
  # GET label_types/1/labels.xml
  def index
    @label_type = LabelType.find(params[:label_type_id])
    @labels = @label_type.labels

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @labels.to_xml }
    end
  end

  # GET label_types/1/labels/1
  # GET label_types/1/labels/1.xml
  def show
    @label = Label.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @label.to_xml }
    end
  end

  # GET label_types/1/labels/new
  def new
    @label_type = LabelType.find(params[:label_type_id])
    @label = @label_type.labels.new
  end

  # GET label_types/1/labels/1;edit
  def edit
    @label_type = LabelType.find(params[:label_type_id])
    @label = @label_type.labels.find(params[:id])
  end

  # POST label_types/1/labels
  # POST label_types/1/labels.xml
  def create
    @label_type = LabelType.find(params[:label_type_id])
    @label = @label_type.labels.new(params[:label])
    @label.label_type = @label_type

    respond_to do |format|
      begin
        @label.save!
        flash[:notice] = 'Label was successfully created.'
        format.html { redirect_to labels_url(@label_type) }
        format.xml  { head :created, :location => label_url(@label) }
      rescue ActiveRecord::RecordInvalid => e
        @label.valid?
        format.html { render :action => "new" }
        format.xml  { render :xml => @label.errors.to_xml }
	  	end

    end
  end

  # PUT label_types/1/labels/1
  # PUT label_types/1/labels/1.xml
  def update
	  @label_type = LabelType.find(params[:label_type_id])
	  @label = @label_type.labels.find(params[:id])

    respond_to do |format|
      if @label.update_attributes(params[:label])
        flash[:notice] = 'Label was successfully updated.'
        format.html { redirect_to labels_url(@label_type) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @label.errors.to_xml }
      end
    end
  end

  # DELETE label_types/1/labels/1
  # DELETE label_types/1/labels/1.xml
  def destroy
    @label = Label.find(params[:id])
    @label.destroy

    respond_to do |format|
      format.html { redirect_to labels_url }
      format.xml  { head :ok }
    end
  end
end
