require 'digest/md5'

class Attachment < ActiveRecord::Base

  validates_format_of :mime_type, :as => :attachment,
    :with => /^image/,
    :message => '-- you can only upload pictures'

  validates_length_of :file, :as => :attachment, :in => 1.byte..1.megabyte

  belongs_to  :resource_property
  
  def Attachment.store_rp_file(resource_property, options)
    # Should we remove it?
    if (options.delete(:remove) != 'f') && resource_property && resource_property.attachment
      resource_property.attachment.destroy
      resource_property.attachment = nil
    end

    # Is file supplied?
    a = options[:value] || options[:attachment]
    if not file_provided?(a)
      options[:value] = options[:attachment] = nil
      return options
    end

    # Prepare new or replace existing attachment
    attachment = (resource_property && resource_property.attachment) || Attachment.new
    attachment.size = a.length
    attachment.filename = sanitize_filename(a.original_filename)
    attachment.file = a.read
    attachment.mime_type = a.content_type.chomp
    attachment.md5 = Digest::MD5.hexdigest(attachment.file)
    
    # Is it valid?
    if attachment. valid?
      options[:value] = attachment.filename
      options[:attachment] = attachment
    else
      options[:value] = options[:attachment] = nil
    end
    
    return options
  end

  private

  def Attachment.file_provided?(file)
    file.respond_to?(:read) and file.size.nonzero?
  end
  
  def Attachment.sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''
            
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^\w\.\-]/, '_'
    end
  end

end
