class Admin::CommentsController < ApplicationController
  layout 'admin'
  before_filter {|c| c.admin_authorize(['System manager'])}

   def index
      @comments = Comment.list_all_comments['content_arrays']
      respond_to do |format|
        format.html # index.rhtml
        format.xml  { render :xml => @comments.to_xml }
      end
   end

    def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to admin_comments_url }
      format.xml  { head :ok }
    end
  end

  def show
    @comment= Comment.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @comment.to_xml }
    end
  end


 def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
    if params[:valid] != nil
      @comment.update_attribute(:is_valid, params[:valid] ? 1 : 0)
    end
    if params[:spam] != nil
      @comment.update_attribute(:is_spam, params[:spam])
    end
    if params[:spam] == nil && params[:valid] == nil
        @comment.update_attributes(params[:comment])
    end
       format.html { redirect_to admin_comments_url }
       format.xml  { head :ok }
    end
  end

end
