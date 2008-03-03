class Admin::AttachmentsController < ApplicationController
  # GET /attachment/1
  # GET /attachment/1.xml
  def show
    attachment = Attachment.find(params[:id])

    # send file
    response.headers['Last-Modified'] = attachment.updated_at.httpdate
    send_data attachment.file, :filename => attachment.filename, :type => attachment.mime_type, :disposition => "inline"
  end
end
