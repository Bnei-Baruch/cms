class Admin::AttachmentsController < ApplicationController
  # GET /attachment/1
  # GET /attachment/1.xml
  def show
    attachment = Attachment.find(params[:id])
    
    minTime = Time.rfc2822(request.env["HTTP_IF_MODIFIED_SINCE"]) rescue nil
    if minTime and (attachment.updated_at < minTime)
      # use cached version
      render_text '', '304 Not Modified'
    else
      # send image
      response.headers['Last-Modified'] = attachment.updated_at.httpdate
      send_data attachment.file, :filename => attachment.filename, :type => attachment.mime_type, :disposition => "inline"
    end
  end
end
