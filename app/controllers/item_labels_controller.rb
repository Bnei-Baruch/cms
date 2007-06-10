class ItemLabelsController < ApplicationController

  before_filter :load_item

  # GET /items/1/labels
  # GET /items/1/labels.xml
  def index
    @labels = @item.attrs
    @label_types = LabelType.find(:all).collect{|lt| [lt.hrid, lt.id]}.sort
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
    @item = Item.find(params[:item_id])

    begin
	    @item.labels << help_update_label(
                params[:label][:label_type_id],
                params[:label][:hrid],
								params[:label]
								)
		rescue ActiveRecord::RecordInvalid => e
				render :action => :new
				return
		end
    xml_ok_result = lambda  { head :created, :location => item_label_url(@item) }
		save_me('Label was successfully created.', "new", xml_ok_result) { @item.save }
  end

  # PUT /items/1/labels/1
  # PUT /items/1/labels/1.xml
  def update
    @label = Label.find(params[:id])
    begin
      Item.transaction do
		    @item.labels.delete(@label)
		    @item.labels << help_update_label(
	                params[:label][:label_type_id],
	                params[:label][:hrid],
									params[:label]
									)
			end
		rescue ActiveRecord::RecordInvalid => e
				render :action => :new
				return
		end
    xml_ok_result = lambda  { head :ok }
		save_me('Label was successfully updated.', "edit", xml_ok_result) {
																				@item.update_attributes(params[:item]) }
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

	def help_update_label(label_type_id, hrid, label)
		@label_type = LabelType.find(label_type_id)
    @label = @label_type.labels.find_by_hrid(hrid)
    if @label.nil?
	    @label = @label_type.labels.new(label)
	    @label.label_type = @label_type
	  end
	  @label
  end

  def save_me(notice, action, xml_ok_result, &block)
    respond_to do |format|
      if yield
        flash[:notice] = notice
        format.html { redirect_to item_labels_url(@item) }
        format.xml  { xml_ok_result.call }
      else
        format.html { render :action => action }
        format.xml  { render :xml => @item.errors.to_xml }
      end
    end
  end

  def load_item
    @item = Item.find(params[:item_id])
  end
end
