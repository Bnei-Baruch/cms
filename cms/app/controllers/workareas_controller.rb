class WorkareasController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @workarea_pages, @workareas = paginate :workareas, :per_page => 10
  end

  def show
    @workarea = Workarea.find(params[:id])
  end

  def new
    @workarea = Workarea.new
  end

  def create
    @workarea = Workarea.new(params[:workarea])
    if @workarea.save
      flash[:notice] = 'Workarea was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @workarea = Workarea.find(params[:id])
  end

  def update
    @workarea = Workarea.find(params[:id])
    if @workarea.update_attributes(params[:workarea])
      flash[:notice] = 'Workarea was successfully updated.'
      redirect_to :action => 'show', :id => @workarea
    else
      render :action => 'edit'
    end
  end

  def destroy
    Workarea.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
