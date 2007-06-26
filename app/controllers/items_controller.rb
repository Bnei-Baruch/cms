class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @object_types = ObjectType.find(:all).collect{|ot| [ot.name, ot.id]}.sort
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
    @label = TextLabel.new()
    @labels = @item.labels
  end

  # GET /items/1;edit
  def edit
    @item = Item.find(params[:id])

    @label = @item.label ? @item.label : TextLabel.new()
  end

  # POST /items
  # POST /items.xml
  def create
    respond_to do |format|
      begin
        Item.transaction do

          #Create Object
          @item = Item.create(params[:item][:object_type_id], params[:item])

          #Object name (predefined label)
          @label = create_name_label
          @item.label = @label
          #Add new labels
          @labels = []
          @a = 1
          params[:labels].each_value do |label|
            @a += 1
            temp = TextLabel.new(label.merge({"label_type_id" => 39}))
            @labels << temp
          end
#          render :text => @labels.size
#          return
          
          @item.labels << @labels
         
          @item.save!
        end

        #successful redirects
        flash[:notice] = 'Item was successfully created.'
        format.html { redirect_to items_url }
        format.xml  { head :created, :location => item_url(@item) }

      rescue ActiveRecord::RecordInvalid => e
        @item.valid?
        @label.valid?
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors.to_xml }
      end
    end
  end

  # GET /items/new;add_label
  def add_label
    #@label = @label_type.labels.new
    @label = TextLabel.new #THIS SHOULD BE RELACED
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    respond_to do |format|
      begin
        Item.transaction do
          #update Object
          @item = Item.find(params[:id])
          @item.update_attributes(params[:item])

          #update Object name (predefined label)
          if @item.label
            @item.label.update_attributes(params[:label])
          else
            @label = create_name_label
            @item.label = @label
            @item.save!
          end
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

end
