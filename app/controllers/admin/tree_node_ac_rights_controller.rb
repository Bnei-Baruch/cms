class Admin::TreeNodeAcRightsController < ApplicationController
  layout 'admin'
  
  before_filter {|c| c.admin_authorize(['Nodes Access Rights'])}

  # GET /tree_node_ac_rights
  # GET /tree_node_ac_rights.xml
  def index
    @tree_node_ac_rights = TreeNodeAcRight.find(:all)
     
  # @tree_node_ac_rights = TreeNodeAcRight.find_by_sql("select tat.* from tree_node_ac_rights tat
  #   where tat.group_id in (select group_id from groups_users gu where gu.group_id=tat.group_id and user_id =#{AuthenticationModel.current_user})")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tree_node_ac_rights }
    end
  end

  # GET /tree_node_ac_rights/1
  # GET /tree_node_ac_rights/1.xml
  def show
    @tree_node_ac_rights = TreeNodeAcRight.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tree_node_ac_rights }
    end
  end

  # GET /tree_node_ac_rights/new
  # GET /tree_node_ac_rights/new.xml
  def new
    @tree_node_ac_rights = TreeNodeAcRight.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tree_node_ac_rights }
    end
  end

  # GET /tree_node_ac_rights/1/edit
  def edit
    @tree_node_ac_rights = TreeNodeAcRight.find(params[:id])
  end

  # POST /tree_node_ac_rights
  # POST /tree_node_ac_rights.xml
  def create
    @tree_node_ac_rights = TreeNodeAcRight.new(params[:tree_node_ac_rights])

    respond_to do |format|
      if @tree_node_ac_rights.save
        flash[:notice] = 'TreeNodeAcRights was successfully created.'
        format.html { redirect_to(admin_tree_node_ac_right_path(@tree_node_ac_rights)) }
        format.xml  { render :xml => @tree_node_ac_rights, :status => :created, :location => @tree_node_ac_rights }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tree_node_ac_rights.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tree_node_ac_rights/1
  # PUT /tree_node_ac_rights/1.xml
  def update
    @tree_node_ac_rights = TreeNodeAcRight.find(params[:id])

    respond_to do |format|
      if @tree_node_ac_rights.update_attributes(params[:tree_node_ac_rights])
        flash[:notice] = 'TreeNodeAcRights was successfully updated.'
        format.html { redirect_to(admin_tree_node_ac_right_path(@tree_node_ac_rights)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tree_node_ac_rights.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tree_node_ac_rights/1
  # DELETE /tree_node_ac_rights/1.xml
  def destroy
    @tree_node_ac_rights = TreeNodeAcRight.find(params[:id])
    @tree_node_ac_rights.destroy

    respond_to do |format|
      format.html { redirect_to admin_tree_node_ac_rights_path }
      format.xml  { head :ok }
    end
  end
end
