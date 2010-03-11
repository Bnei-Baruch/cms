class Admin::AttachmentsController < ApplicationController
  
  # No authorization required to see pictures
  #  before_filter {|c| c.admin_authorize(['System manager'])}
  
  # GET /attachment/1
  # GET /attachment/1.xml
  def show
    attachment = Attachment.find(params[:id])

    # send file
    if attachment.file
      response.headers['Last-Modified'] = attachment.updated_at.httpdate
      send_data attachment.file, :filename => attachment.filename, :type => attachment.mime_type, :disposition => "inline"
    end
    return
  end
end
