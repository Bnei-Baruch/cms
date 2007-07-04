class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @object_types = ObjectType.find(:all).collect{|ot| [ot.name, ot.id]}.sort
    @items = Item.find(:all, :order => "id DESC")

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
    @label = TextLabel.new()
    @labels = @item.labels
    @label_types = LabelType.regular_label_types.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort
  end

  # GET /items/1;edit
  def edit
    @item = Item.find(params[:id])
    @labels = @item.free_labels
    @label_types = LabelType.regular_label_types.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort

    @label = @item.label ? @item.label : TextLabel.new()
  end

  # POST /items
  # POST /items.xml
  def create
    @label_types = LabelType.regular_label_types.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort

    respond_to do |format|
      begin
        Item.transaction do

          #Create Object
          @item = Item.create(params[:item][:object_type_id], params[:item])

          #Object name (predefined label)
          @label = create_name_label
          @item.label = @label
          #Add new labels
          update_metadata
          @item.save!
        end

        #successful redirects
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to items_url }
        format.xml  { head :created, :location => item_url(@item) }

      rescue ActiveRecord::RecordInvalid => e
        #        @item.valid?
        @label.valid?
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors.to_xml }
      end
    end
  end

  # GET /items;add_label
  def add_label
    @label_type = LabelType.find(params[:select_label_type])
    @label = @label_type.labels.new(:label_type_id => @label_type.id)
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @label_types = LabelType.regular_label_types.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort
    respond_to do |format|
      begin
        Item.transaction do
          #update Object
          @item = Item.find(params[:id])
          @item.update_attributes(params[:item])

          #update Object name (predefined label)
          if @item.label
            @item.label.update_attributes(params[:label])
            @label = @item.label
          else
            @label = create_name_label
            @item.label = @label
          end

          update_metadata  

          @item.save!
        end


        #successful redirects
        flash[:notice] = 'Item was successfully updated.'
        format.html { redirect_to items_url }
        format.xml  { head :ok }

      rescue ActiveRecord::RecordInvalid => e
        @item.valid?
        @label.valid?
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors.to_xml }
      end

    end
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

  private

  def create_name_label
    label_params = params[:label]
    label_params.merge!({"label_type_id" => Item.predefined_label_type.id})
    TextLabel.new(label_params)
  end
  
  def update_metadata
    if params[:labels]
      new_labels = []
      params[:labels].each do |index, label|
        fixed_index = index.to_i + 1
        label_type = LabelType.find(label[:label_type_id])
        existing_label = @item.labels.find_by_id(label[:id])
        existing_description = @item.descriptions.find_by_label_id(label[:id])
        if (existing_description)
          existing_description.update_attributes!(:free =>true, :label_order => fixed_index)
          existing_description.label.update_attributes!(label)
        else
          new_description = Description.new(:free =>true, :label_order => fixed_index)
          new_description.item = @item
          new_description.label = label_type.labels.new(label)
          new_description.save!
        end
      end
    end
    @labels = @item.free_labels
  end
  

end
