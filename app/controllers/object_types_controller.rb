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
    @label = TextLabel.new(:label_type_id => ObjectType.predefined_label_type)
    update_label_types_select()
    @label_rules = @object_type.label_rules

  end

  # GET /object_types/1;edit
  def edit
    @object_type = ObjectType.find(params[:id])
    @label = @object_type.label
    @label_rules = @object_type.label_rules
    
    existing_label_types = []
    if params[:label_rules]
    	params[:label_rules].each_value{|lr| existing_label_types << lr[:label_type_id]}
  	else
  		if @label_rules
  			@label_rules.each{|lr| existing_label_types << lr.label_type.id.to_s}
  		end
    end
    update_label_types_select(existing_label_types)
  end

  # POST /object_types
  # POST /object_types.xml
  def create
    @object_type = ObjectType.create(params[:object_type])
    @label_rules = @object_type.label_rules
    existing_label_types = []
    if params[:label_rules]
    	params[:label_rules].each_value{|lr| existing_label_types << lr[:label_type_id]}
    end
    update_label_types_select(existing_label_types)
    respond_to do |format|
      begin
        ObjectType.transaction do
          @label = @object_type.build_label(params[:label])
    			if params[:label_rules]
						params[:label_rules].each_value { |label_rule| @object_type.label_rules.build(label_rule) }
   			 	end
          @object_type.save!
        end
        flash[:notice] = 'Object Type was successfully created.'
        format.html { redirect_to object_types_url }
        format.xml  { head :created, :location => object_type(@object_type) }
      rescue ActiveRecord::RecordInvalid => e
        @object_type.valid?
        # @label.valid? # force checking of errors even if  Object Type failed
        format.html { render :action => "new" }
        format.xml  { render :xml => @object_type.errors.to_xml }
      end
    end
  end
  # GET /items;add_label
  def add_label_rule
    existing_label_types =[]
    if params[:existing_label_types]
	    existing_label_types = params[:existing_label_types].split('_')
	  end
  	existing_label_types << params[:select_label_type]

		update_label_types_select(existing_label_types)
    @label_type = LabelType.find(params[:select_label_type])
    @label_rule = @label_type.label_rules.new(:label_type_id => @label_type.id)

  end

  # PUT /object_types/1
  # PUT /object_types/1.xml
  def update
    @object_type = ObjectType.find(params[:id])
    @label = @object_type.label
    @label_rules = @object_type.label_rules
    @object_type.attributes = params[:object_type]
    @label.attributes = params[:label]

    existing_label_types = []
    if params[:label_rules]
    	params[:label_rules].each_value{|lr| existing_label_types << lr[:label_type_id]}
  	else
  		if @label_rules
  			@label_rules.each{|lr| existing_label_types << lr.label_type.id.to_s}
  		end
    end
    update_label_types_select(existing_label_types)
    
    update_label_rules

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
  
  private
	def update_label_types_select(existing_label_types = [])
    @label_types = LabelType.regular_label_types.reject{|item| existing_label_types.include?(item.id.to_s)}.map{|lt| ["#{lt.name}\t[#{lt.type_short}]", lt.id]}.sort
  end
  
  def update_label_rules
		if params[:label_rules]
			params[:label_rules].each_value do |label_rule|
				existing_label_rule = @object_type.label_rules.find_by_id(label_rule[:id])
				if existing_label_rule
					existing_label_rule.update_attributes!(label_rule)
				else
					@object_type.label_rules.build(label_rule)
				end
			end
	 	end
  	
    # @label_rules = []
    # if params[:label_rules]
    #   #new_label_rules = []
    #   params[:label_rules].each do |index, label_rule|
    #     #label_type = LabelType.find(label_rule[:label_type_id])
    #     @label_rules << label_rule
    #     existing_label_rule = @object_type.label_rules.find_by_id(label_rule[:id])
    #     if (existing_label_rule)
    #       existing_label_rule.update_attributes!(label_rule, :object_type_id => @object_type.id)
    #       existing_label_rule.label.update_attributes!(label_rule)
    #     else
    #       @object_type.label_rules << LabelRule.new(label_rule)
    #       #@temp = new_label_rule
    #       #new_label_rule.save!
    #     end
    #   end
    # end
    # #params[:label_rules].each_value{|val| @label_rules << val}
    # #@
  end
  
end
