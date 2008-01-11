class AttachmentsController < ApplicationController
  # GET /attachment/1
  # GET /attachment/1.xml
  def show
    attachment = Attachment.find(params[:id])
    send_data attachment.file, :filename => attachment.filename, :type => attachment.mime_type, :disposition => "inline"
  end
end
