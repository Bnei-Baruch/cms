class Admin::UsersController < ApplicationController
  layout 'admin'
  
  before_filter {|c| c.admin_authorize(['User manager'])}

  # GET /users
  # GET /users.xml
  def index
    @users = User.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @groups = @user.groups.find(:all, :order=>["groupname"])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    group_ids = params[:user][:group_ids] ||= []
    params[:user][:group_ids] = nil
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save 
        @user.group_ids=group_ids
        @user.save
        flash[:notice] = 'User was successfully created.'
        format.html { redirect_to admin_user_path(@user) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    params[:user][:group_ids] ||= []
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to admin_user_path(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    if @user.destroy == false
      error_msg = ""
      @user.errors.each_full{|msg| error_msg = error_msg + msg }
      if error_msg == ""
        error_msg = "Can't delete the user." 
      end
      flash[:notice]= error_msg
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
      format.xml  { head :ok }
    end
  end
end
