require 'digest/md5'
require 'mini_magick'

class Attachment < ActiveRecord::Base

  validates_length_of :file, :as => :attachment, :maximum => 1.megabyte

  belongs_to  :resource_property

  with_options :class_name => "Attachment", :foreign_key => "thumbnail_id" do |opt|
    opt.has_many   :thumbnails,
                   :dependent => :delete_all,
                   :conditions => "filename <> 'self'"
    opt.belongs_to :parent
    opt.has_one    :myself,
                   :conditions => "filename = 'self'"
  end

  before_save :create_thumbnails_and_apply_geometry
  
  attr_accessor :dont_process

  def Attachment.store_rp_file(resource_property, options)
    # Should we first remove an old one?
    if (options.delete(:remove) != 'f')
      remove_thumbnails(resource_property)
    end

    # Is file supplied?
    att = options[:value]
    if not file_provided?(att)
      options[:value] = nil
      return options
    end

    # Prepare new or replace an existing attachment
    remove_thumbnails(resource_property) # remove old thumbnails if exist
    attachment = (resource_property && resource_property.attachment) || Attachment.new
    attachment.size = att.length
    attachment.filename = sanitize_filename(att.original_filename)
    attachment.file = att.read
    attachment.mime_type = att.content_type.chomp
    attachment.md5 = Digest::MD5.hexdigest(attachment.file)
    
    # Is it valid?
    if attachment.valid?
      options[:value] = attachment.filename
      options[:attachment] = attachment
    else
      options[:value] = options[:attachment] = nil
    end

    return options
  end

  def create_thumbnails_and_apply_geometry
    return if dont_process or !is_image?
    
    # Format of geometry string:
    # self:geom;thumb1:geom;...
    geometry = {}
    geometry_string = self.resource_property.property.geometry rescue ""
    geometry_string.scan(/(\w+):([\w%!><]+)/) { |key, value|
      geometry[key] = value
    }
    if geometry.empty? || ! geometry.has_key?('self')
      # Save 'self' as an exact copy of an original image
      geometry['self'] = '100%x100%'
    end
    
    geometry.each { |name, geom|
      self.thumbnails << self.resize(geom, name)
    }
  end

  def is_image?
    mime_type =~ /^image/
  end

  protected

  def resize(geometry, name)
    image = MiniMagick::Image.from_blob(self.file, self.mime_type.split('/').last)
    image.resize geometry
    image.strip
    new_image = image.to_blob
    thumb = Attachment.new(:filename => name)
    thumb.file = new_image
    thumb.size = new_image.size
    thumb.md5 = Digest::MD5.hexdigest(thumb.file)
    thumb.mime_type = self.mime_type
    thumb.dont_process = true
    thumb
  end

  def has_thumbnails?
    self.thumbnails.size > 0
  end

  private

  def Attachment.remove_thumbnails(resource_property)
    return if ! (resource_property && resource_property.attachment) or ! resource_property.attachment.is_image?
    resource_property.attachment.thumbnails.each {|thumb|
      thumb.destroy
    }
    resource_property.attachment.myself.destroy
    resource_property.attachment.destroy
    resource_property.attachment = nil
  end

  def Attachment.file_provided?(file)
    file.respond_to?(:read) and file.size.nonzero?
  end
  
  def Attachment.sanitize_filename(filename)
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub!(/^.*(\\|\/)/, '')
            
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub!(/[^\w\.\-]/, '_')
    end
  end
end

module MiniMagick
  class Image
    def to_blob
      begin
        content = ""
        file = File.open(@path, File::RDONLY)
        file.binmode
        content = file.read
      ensure
        file.close if file
      end
      content
    end
  end
end
