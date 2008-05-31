require 'csv'

class Admin::UrlMigrationsController < ApplicationController
  layout 'admin'
  #check security access
  before_filter {|c| c.admin_authorize(['System manager'])}
  

  # GET /url_migrations
  # GET /url_migrations.xml
  def index
    @url_migrations = UrlMigration.find(:all)

	@run_export_window = false
	if $export_file
	  $export_file = false	
	  @run_export_window = true
	  @file_url = 'http://' + request.env["HTTP_HOST"] + '/migrations.csv'
	end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @url_migrations }
    end
  end

  # GET /url_migrations/1
  # GET /url_migrations/1.xml
  def show
    @url_migration = UrlMigration.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @url_migration }
    end
  end

  # GET /url_migrations/new
  # GET /url_migrations/new.xml
  def new
    @url_migration = UrlMigration.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @url_migration }
    end
  end

  # GET /url_migrations/1/edit
  def edit
    @url_migration = UrlMigration.find(params[:id])
  end

  # POST /url_migrations
  # POST /url_migrations.xml
  def create
    @url_migration = UrlMigration.new(params[:url_migration])

    respond_to do |format|
      if @url_migration.save
        flash[:notice] = 'UrlMigration was successfully created.'
        format.html { redirect_to admin_url_migrations_path }
        format.xml  { render :xml => @url_migration, :status => :created, :location => @url_migration }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @url_migration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /url_migrations/1
  # PUT /url_migrations/1.xml
  def update
    @url_migration = UrlMigration.find(params[:id])

    respond_to do |format|
      if @url_migration.update_attributes(params[:url_migration])
        flash[:notice] = 'UrlMigration was successfully updated.'
        format.html { redirect_to admin_url_migrations_path }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @url_migration.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /url_migrations/1
  # DELETE /url_migrations/1.xml
  def destroy
    @url_migration = UrlMigration.find(params[:id])
    @url_migration.destroy

    respond_to do |format|
      format.html { redirect_to(admin_url_migrations_url) }
      format.xml  { head :ok }
    end
  end

  def export
   	@file_name = 'public/migrations.csv'
	if File.exist?(@file_name)
	  File.delete(@file_name) 
	end

    @url_migrations = UrlMigration.find(:all)
    CSV.open(@file_name, 'w') do |writer|
      writer << ['Source', 'Target', 'Action', 'State']
      for @url_migration in @url_migrations
        writer << [@url_migration.source, @url_migration.target, @url_migration.action, @url_migration.state]
      end 
    end 

	$export_file = true

    respond_to do |format|
      format.html { redirect_to(admin_url_migrations_url) }
      format.xml  { head :ok }
    end

  end

  def merge
	render :partial => 'upload_file', :layout => 'admin'
  end

  def import
	render :partial => 'upload_file', :layout => 'admin'
  end

  def cleanup
    UrlMigration.delete_all "upper(state) = 'DELETED'"

    respond_to do |format|
	  flash[:notice] = 'All the deleted URL Migrations were cleaned up!'
      format.html { redirect_to(admin_url_migrations_url) }
      format.xml  { head :ok }
    end

  end
  
 
  def import_complete	
	buf = params['upload']['datafile'].read
    respond_to do |format|
      res = UrlMigration.update_from_file(buf, true)
      if (res == "")
        flash[:notice] = 'The file was successfully imported!'
        format.html { redirect_to(admin_url_migrations_url) }
        format.xml  { head :ok }
      else
        res = "Error while import file \"" + params['upload']['datafile'].original_filename + "\":<br />" + res
        flash[:notice] = res
        format.html { redirect_to(admin_url_migrations_url) }
        format.xml  { render :xml => res, :status => :expectation_failed }
      end
    end

  end 
  

  def merge_complete
	buf = params['upload']['datafile'].read
    respond_to do |format|
      res = UrlMigration.update_from_file(buf, false)
      if (res == "")
        flash[:notice] = 'The file was successfully merged!'
        format.html { redirect_to(admin_url_migrations_url) }
        format.xml  { head :ok }
      else
            res = "Error while merge file \"" + params['upload']['datafile'].original_filename + "\":<br />" + res
        flash[:notice] = res
        format.html { redirect_to(admin_url_migrations_url) }
        format.xml  { render :xml => res, :status => :expectation_failed }
      end
  end   
  end
end
