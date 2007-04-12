class LabelTypesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @label_type_pages, @label_types = paginate :label_types, :per_page => 10
  end

  def show
    @label_type = LabelType.find(params[:id])
  end

  def new
    @label_type = LabelType.new
  end

  def create
    @label_type = LabelType.new(params[:label_type])
    if @label_type.save
      flash[:notice] = 'LabelType was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @label_type = LabelType.find(params[:id])
  end

  def update
    @label_type = LabelType.find(params[:id])
    if @label_type.update_attributes(params[:label_type])
      flash[:notice] = 'LabelType was successfully updated.'
      redirect_to :action => 'show', :id => @label_type
    else
      render :action => 'edit'
    end
  end

  def destroy
    LabelType.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
