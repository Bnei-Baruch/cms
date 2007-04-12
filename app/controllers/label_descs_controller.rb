class LabelDescsController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @label_desc_pages, @label_descs = paginate :label_descs, :per_page => 10
  end

  def show
    @label_desc = LabelDesc.find(params[:id])
  end

  def new
    @label_desc = LabelDesc.new
  end

  def create
    @label_desc = LabelDesc.new(params[:label_desc])
    if @label_desc.save
      flash[:notice] = 'LabelDesc was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @label_desc = LabelDesc.find(params[:id])
  end

  def update
    @label_desc = LabelDesc.find(params[:id])
    if @label_desc.update_attributes(params[:label_desc])
      flash[:notice] = 'LabelDesc was successfully updated.'
      redirect_to :action => 'show', :id => @label_desc
    else
      render :action => 'edit'
    end
  end

  def destroy
    LabelDesc.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
