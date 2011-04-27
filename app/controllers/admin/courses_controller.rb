class Admin::CoursesController < ApplicationController
  layout 'admin'
  append_before_filter {|c| c.admin_authorize(c.site_settings[:editors_of_list_of_courses])}

  # GET /courses
  # GET /courses.xml
  def index
    @courses = Course.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    @course = Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        flash[:notice] = 'Course was successfully created.'
        format.html { redirect_to :action => 'index' }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Course was successfully updated.'
        format.html { redirect_to :action => 'index' }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    #   ******************
    #   Check permissions!
    unless @course
      flash[:notice] = "Access denied. User can't delete courses"
      render :action => 'index'
      return
    end
    #   ******************

    flash[:notice] = 'Course was successfully deleted.'
    @course.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.xml  { head :ok }
      format.json { head(:ok).to_json}
    end
  end

  def excel
    content = Student.list_all_students.to_excel(
        :title => "BB-Students #{Time.now.strftime("%Y-%m-%d")}",
        :author => 'BB',
        :company => 'BB',
        :only => [:name, :telephone, :email, :adwords, :listname],
        :methods => [:excel_date],
        :headers => {:excel_date => _(:'date'), :name => _(:'name'), :telephone => _(:'tel'), :email => _(:'email'), :adwords => _(:'campaign'), :listname => _(:'list_name')}
    )
    send_zip_file 'BB-Students', content
  end

  private

  require 'zip/zip'
  
  def send_zip_file(file_name, content)
    time_now = Time.now

    file_path = "#{Rails.root}/tmp/#{file_name}_#{time_now.strftime("%d-%m-%Y")}_#{Process.pid}.xml"
    zip_file_path = "#{Rails.root}/tmp/#{file_name}_#{time_now.strftime("%d-%m-%Y")}_#{Process.pid}.zip"
    File.unlink file_path rescue nil
    File.unlink zip_file_path rescue nil
    my_file = File.new(file_path, 'w+')
    my_file.syswrite(content)
    my_file.close
    Zip::ZipFile.open(zip_file_path, 'w') do |zipfile|
      zipfile.add(File.basename(file_path), my_file.path)
    end
    send_file(zip_file_path, :type => 'application/zip')
  end
  
end
