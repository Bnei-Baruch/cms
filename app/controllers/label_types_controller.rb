class LabelTypesController < ApplicationController
  # GET /label_types
  # GET /label_types.xml
  before_filter :get_language
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
	  @label_type_desc = @label_type.label_type_descs.detect {|ltd| ltd.language.eql?@lang_obj}
  end

  # POST /label_types
  # POST /label_types.xml
  def create
	  @label_type = LabelType.create(params[:label_type])
    respond_to do |format|
      begin
        LabelType.transaction do
          @label_type_desc = @label_type.label_type_descs.build(params[:label_type_desc])
          @label_type_desc.language = @lang_obj
          @label_type.save!
          @label_type_desc.save!
        end

        flash[:notice] = 'LabelType was successfully created.'
        format.html { redirect_to label_types_url }
        format.xml  { head :created, :location => label_type_url(@label_type) }

      rescue ActiveRecord::RecordInvalid => e
        @label_type.valid?
        @label_type_desc.valid?
        format.html { render :action => "new" }
        format.xml  { render :xml => @label_type.errors.to_xml }
      end
    end
  end

  # PUT /label_types/1
  # PUT /label_types/1.xml
  def update
	  respond_to do |format|
	    begin
		    LabelType.transaction do
		      @label_type = LabelType.find(params[:id])
			    @label_type.attributes = params[:label_type]
		      @label_type_desc = @label_type.label_type_descs.detect {|ltd| ltd.language.eql?@lang_obj}
		      if @label_type_desc
		        @label_type_desc.attributes = params[:label_type_desc]
		      else
	          @label_type_desc = @label_type.label_type_descs.build(params[:label_type_desc])
	          @label_type_desc.language = @lang_obj
		      end
		      @label_type.save!
		      @label_type_desc.save!
	      end

	      flash[:notice] = 'LabelType was successfully updated.'
	      format.html { redirect_to label_types_url }
	      format.xml  { head :ok }
	  	rescue ActiveRecord::RecordInvalid => e
				@label_type.valid?
				@label_type_desc.valid?
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

protected

  def get_language
    lang = "eng"
    @lang_obj = Language.find_by_abbr(lang)
  end

end
