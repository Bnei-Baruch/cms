class AttachmentsController < ApplicationController
  
  def get_image
    #    :image_id/:image_name.:format
    image_id = params[:image_id]
    image_name = params[:image_name]
    format = params[:format]

    begin
      attachment = Attachment.get_image(image_id, image_name, format)
      if attachment.nil?
        head :status => 404
        return
      end
    rescue Exception => e
      head :status => 404
      return
    end

    # send file
    #    response.headers['Last-Modified'] = attachment.updated_at.httpdate
    if stale?(:last_modified => attachment.updated_at.utc, :etag => attachment)
      send_data attachment.file,
        :filename => attachment.filename,
        :type => attachment.mime_type,
        :disposition => "inline"
    end
  end
end
