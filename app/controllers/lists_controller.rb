class ListsController < ApplicationController
	layout 'admin'
  # GET /lists
  # GET /lists.xml
  def index
    @lists = List.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @lists.to_xml }
    end
  end

  # GET /lists/1
  # GET /lists/1.xml
  def show
    @list = List.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @list.to_xml }
    end
  end

  # GET /lists/new
  def new
    @list = List.new(params[:list])
  end

  # GET /lists/1;edit
  def edit
    @list = List.find(params[:id])
  end

  # POST /lists
  # POST /lists.xml
  def create
    @list = List.new(params[:list])

    respond_to do |format|
      if @list.save
        flash[:notice] = 'List was successfully created.'
        format.html { redirect_to list_url(@list) }
        format.xml  { head :created, :location => list_url(@list) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @list.errors.to_xml }
      end
    end
  end

  # PUT /lists/1
  # PUT /lists/1.xml
  def update
    @list = List.find(params[:id])

    respond_to do |format|
      if @list.update_attributes(params[:list])
        flash[:notice] = 'List was successfully updated.'
        format.html { redirect_to list_url(@list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @list.errors.to_xml }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.xml
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_url }
      format.xml  { head :ok }
    end
  end
end
