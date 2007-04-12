class LabelTypeDescsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @label_type_desc_pages, @label_type_descs = paginate :label_type_descs, :per_page => 10
  end

  def show
    @label_type_desc = LabelTypeDesc.find(params[:id])
  end

  def new
    @label_type_desc = LabelTypeDesc.new
  end

  def create
    @label_type_desc = LabelTypeDesc.new(params[:label_type_desc])
    if @label_type_desc.save
      flash[:notice] = 'LabelTypeDesc was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @label_type_desc = LabelTypeDesc.find(params[:id])
  end

  def update
    @label_type_desc = LabelTypeDesc.find(params[:id])
    if @label_type_desc.update_attributes(params[:label_type_desc])
      flash[:notice] = 'LabelTypeDesc was successfully updated.'
      redirect_to :action => 'show', :id => @label_type_desc
    else
      render :action => 'edit'
    end
  end

  def destroy
    LabelTypeDesc.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
