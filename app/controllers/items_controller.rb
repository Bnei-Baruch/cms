class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @object_types = ObjectType.find(:all).collect{|ot| [ot.label.hrid, ot.id]}.sort
    @items = Item.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @items.to_xml }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @item.to_xml }
    end
  end

  # GET /items/new
  def new
    @item = Item.create(params[:item][:object_type_id], params[:item])
    @label = TextLabel.new(:label_type_id => 38)
  end

  # GET /items/1;edit
  def edit
    @item = Item.find(params[:id])
    @label = @item.name_object
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.create(params[:item][:object_type_id], params[:item])
    @item.labels << help_update_label(
                params[:label][:label_type_id],
                params[:label][:hrid],
								params[:label]
								)
    xml_ok_result = lambda  { head :created, :location => item_url(@item) }
		save_me('Item was successfully created.', "new", xml_ok_result, item_url) { @item.save }
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])
    @item.labels.delete(@item.name_object)
    @item.labels << help_update_label(
                params[:label][:label_type_id],
                params[:label][:hrid],
								params[:label]
								)
    xml_ok_result = lambda  { head :ok }
		save_me('Item was successfully updated.', "edit", xml_ok_result, item_url) {
																				@item.update_attributes(params[:item]) }
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to items_url }
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

  def save_me(notice, action, xml_ok_result, url, &block)
    respond_to do |format|
      if yield
        flash[:notice] = notice
        format.html { redirect_to url }
        format.xml  { xml_ok_result.call }
      else
        format.html { render :action => action }
        format.xml  { render :xml => @item.errors.to_xml }
      end
    end
  end
end
