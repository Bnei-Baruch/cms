class Admin::WebsitesController < ApplicationController
  layout 'admin'
  
  #check security access
  before_filter {|c| c.admin_authorize(['System manager'])}
  
  # GET /websites GET /websites.xml
  def index
    @websites = Website.find(:all, :order => 'name')

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @websites.to_xml }
    end
  end

  # GET /websites/1 GET /websites/1.xml
  def show
    @website = Website.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @website.to_xml }
    end
  end

  # GET /websites/new
  def new
    @website = Website.new
  end

  # GET /websites/1;edit
  def edit
    @website = Website.find(params[:id])
  end

  # POST /websites POST /websites.xml
  def create
    @website = Website.new(params[:website])

    respond_to do |format|
      if @website.save
        flash[:notice] = 'Website was successfully created.'
        format.html { redirect_to admin_website_url(@website) }
        format.xml  { head :created, :location => admin_websites_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @website.errors.to_xml }
      end
    end
  end

  # PUT /websites/1 PUT /websites/1.xml
  def update
    @website = Website.find(params[:id])

    respond_to do |format|
      if @website.update_attributes(params[:website])
        flash[:notice] = 'Website was successfully updated.'
        format.html { redirect_to admin_websites_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @website.errors.to_xml }
      end
    end
  end
	
  # DELETE /websites/1 DELETE /websites/1.xml
  def destroy
    @website = Website.find(params[:id])
    @website.destroy

    respond_to do |format|
      format.html { redirect_to admin_websites_url }
      format.xml  { head :ok }
    end
  end
end
