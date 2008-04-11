class Admin::UrlMigrationsController < ApplicationController
	layout 'admin'
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
end
