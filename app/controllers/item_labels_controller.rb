class ItemLabelsController < ApplicationController

  before_filter :load_item

  # GET /items/1/labels
  # GET /items/1/labels.xml
  def index
    @labels = @item.attrs
    @label_types = LabelType.regular_label_types.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort
  end

  # GET /items/1/labels/new
  def new
    @label_type = LabelType.find(params[:item][:label_type_id])
    @label = @label_type.labels.new
		@label.label_type = @label_type
  end

  # GET /items/1/item_labels/1;edit
  def edit
    @label = Label.find(params[:id])
  end

  # POST /items/1/labels
  # POST /items/1/labels.xml
  def create
	  @label_type =  LabelType.find(params[:label][:label_type_id])
    @label = @label_type.labels.new(params[:label])
    respond_to do |format|
	    begin
		    @item.labels << @label
        flash[:notice] = 'Label was successfully created.'
        format.html { redirect_to item_labels_url(@item) }
        format.xml  { head :created, :location => item_label_url(@item) }

  		rescue ActiveRecord::RecordInvalid => e
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors.to_xml }
	   	end
   	end
#    xml_ok_result = lambda  { head :created, :location => item_label_url(@item) }
#		save_me('Label was successfully created.', "new", xml_ok_result) { @item.save }
  end

  # PUT /items/1/labels/1
  # PUT /items/1/labels/1.xml
  def update
    @label = Label.find(params[:id])
    respond_to do |format|
	    begin
		    @label.update_attributes(params[:label])
		    flash[:notice] = 'Label was successfully created.'
        format.html { redirect_to item_labels_url(@item) }
        format.xml  { head :ok }

  		rescue ActiveRecord::RecordInvalid => e
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors.to_xml }
	   	end
   	end


  end

  # DELETE /items/1/labels/1
  # DELETE /items/1/labels/1.xml
  def destroy
    @label = Label.find(params[:id])
    @item.labels.delete(@label)

    respond_to do |format|
      format.html { redirect_to item_labels_url(@item) }
      format.xml  { head :ok }
    end
  end

##########    private     ##################

  private

  def load_item
    @item = Item.find(params[:item_id])
  end
end
