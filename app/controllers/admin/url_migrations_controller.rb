require 'csv'

class Admin::UrlMigrationsController < ApplicationController
  layout 'admin'
  #check security access
  before_filter {|c| c.admin_authorize(['System manager'])}
  
  # GET /url_migrations
  # GET /url_migrations.xml
  def index
    @url_migrations = UrlMigration.find(:all)

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
  
  def import
  end

  def export
  end

  def merge
  end

  def cleanup
  end

  def import_complete
	
	file_name = "tmp/files/" + sanitize_filename(params["upload"]['datafile'].original_filename)
	update_from_file(file_name, true)

    respond_to do |format|
      format.html # import_complete.html.erb
      format.xml  { head :ok }
    end
  end 
  

  def merge_complete
	
	file_name = "tmp/files/" + sanitize_filename(params["upload"]['datafile'].original_filename)
	update_from_file(file_name, false)

    respond_to do |format|
      format.html # merge_complete.html.erb
      format.xml  { head :ok }
    end
  end   
   
private ######### PRIVATE FUNCTIONS #########

  def sanitize_filename(file_name)
    # get only the filename, not the whole path (from IE)
	just_filename = File.basename(file_name) 
	# replace all none alphanumeric, underscore or perioids with underscore
	just_filename.sub(/[^\w\.\-]/,'_') 
  end


  def update_from_file(file_name, delete_existing_migrations)

  	if File.exist?(file_name)
	  File.delete(file_name) 
	end

	DataFile.save(params["upload"])

	if (delete_existing_migrations)
  	  url_migrations = UrlMigration.find(:all)
	  url_migrations.each do |url_migration|
	    url_migration.update_attributes(:state => "Deleted")
	  end
	end

	CSV.open(file_name, 'r') do |row|
      if (row[0] != "Source")
	    url_migration = UrlMigration.find_by_source(row[0])
	    if (url_migration)
	      url_migration.update_attributes(:target => row[1],
		                                  :action => row[2],
										  :state  => row[3])
	    else
		  url_migration = UrlMigration.new(:source => row[0],
										   :target => row[1],
										   :action => row[2],
										   :state  => row[3])		
	    end
	    err = url_migration.save
      end
	  break if !row[0]
	end

	if File.exist?(file_name)
	  File.delete(file_name) 
	end
  end

end
