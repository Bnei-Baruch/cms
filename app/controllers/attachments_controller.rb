class AttachmentsController < ApplicationController
  
	def get_image
    #    :image_id/:image_name.:format
    image_id = params[:image_id]
    image_name = params[:image_name]
    format = params[:format]

    begin
      attachment = Attachment.get_image(image_id, image_name, format)
    rescue Exception => e
      render :text => "404 -- File #{image_name + "." + format} not found + #{e}", :status => 404, :layout => false
      return
    end

    # send file
    response.headers['Last-Modified'] = attachment.updated_at.httpdate
    send_data attachment.file,
      :filename => attachment.filename,
      :type => attachment.mime_type,
      :disposition => "inline"
	end
end
