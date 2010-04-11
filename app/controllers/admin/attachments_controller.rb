class Admin::AttachmentsController < ApplicationController
  
  # No authorization required to see pictures
  #  before_filter {|c| c.admin_authorize(['System manager'])}
  
  # GET /attachment/1
  # GET /attachment/1.xml
  def show
    attachment = Attachment.find(params[:id])
    image_name = attachment.thumbnail_id ? "#{attachment.thumbnail_id}_#{attachment.filename}" : "#{params[:id]}_original"
    format = attachment.mime_type.split("/", 2)[1]
    begin
      attachment = Attachment.get_image(image_name, format)
      if attachment.nil?
        head :status => 404
        return
      end
    rescue Exception => e
      begin
        if format == 'jpg'
          attachment = Attachment.get_image(image_name, 'jpeg')
        elsif format == 'jpeg'
          attachment = Attachment.get_image(image_name, 'jpg')
        end
      rescue Exception => e
        head :status => 404
        return
      end
    end

    # send file
    if attachment.file_content
      response.headers['Last-Modified'] = attachment.updated_at.httpdate
      send_data attachment.file_content, :filename => attachment.filename, :type => attachment.mime_type, :disposition => "inline"
    end
    return
  end
end
