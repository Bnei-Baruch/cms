class ObjectTypesController < ApplicationController
  # GET /object_types
  # GET /object_types.xml
  def index
    @object_types = ObjectType.find(:all, :order => "id ASC")

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @object_types.to_xml }
    end
  end

  # GET /object_types/1
  # GET /object_types/1.xml
  def show
    @object_type = ObjectType.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @object_type.to_xml }
    end
  end

  # GET /object_types/new
  def new
    @object_type = ObjectType.create(params[:object_type])
    @label = TextLabel.new(:label_type_id => 37)
  end

  # GET /object_types/1;edit
  def edit
    @object_type = ObjectType.find(params[:id])
    @label = @object_type.label
  end

  # POST /object_types
  # POST /object_types.xml
  def create
    @object_type = ObjectType.create(params[:object_type])

    respond_to do |format|
      begin
        ObjectType.transaction do
          @label = @object_type.build_label(params[:label])
          @label.save!
          @object_type.save!
        end

        flash[:notice] = 'Object Type was successfully created.'
        format.html { redirect_to object_types_url }
        format.xml  { head :created, :location => object_type(@object_type) }

      rescue ActiveRecord::RecordInvalid => e
        @object_type.valid?
        @label.valid? # force checking of errors even if  Object Type failed
        format.html { render :action => "new" }
        format.xml  { render :xml => @object_type.errors.to_xml }
      end
    end
  end

  # PUT /object_types/1
  # PUT /object_types/1.xml
  def update
    @object_type = ObjectType.find(params[:id])
    @label = @object_type.label
    @object_type.attributes = params[:object_type]
    @label.attributes = params[:label]

    respond_to do |format|
      if @object_type.valid? && @label.valid?

        @object_type.save!
        @label.save!
        flash[:notice] = 'Object Type was successfully updated.'
        format.html { redirect_to object_types_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @object_type.errors.to_xml }
      end
    end
  end

  # DELETE /object_types/1
  # DELETE /object_types/1.xml
  def destroy
    @object_type = ObjectType.find(params[:id])
    @object_type.destroy

    respond_to do |format|
      format.html { redirect_to object_types_url }
      format.xml  { head :ok }
    end
  end
end
