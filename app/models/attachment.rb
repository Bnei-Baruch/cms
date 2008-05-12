require 'digest/md5'
require 'mini_magick'

class Attachment < ActiveRecord::Base

  validates_length_of :file, :as => :attachment, :maximum => 5.megabytes

  belongs_to  :resource_property

  with_options :class_name => "Attachment", :foreign_key => "thumbnail_id" do |opt|
    opt.has_many   :thumbnails,
      :dependent => :delete_all,
      :conditions => "filename <> 'myself'"
    opt.belongs_to :parent
    opt.has_one    :myself,
      :dependent => :delete,
      :conditions => "filename = 'myself'"
  end

  def Attachment.get_image(image_id, image_name, format)
    attachment = find(:first, :conditions => ["id = ?", image_id])
    case image_name
    when 'original'
      attachment = attachment.resource_property.original
    when 'myself'
      attachment = attachment.myself
    else
      if thumbnail = attachment.thumbnails.detect{|th| th.filename.eql?(image_name)}
        attachment = thumbnail
      end
    end
    # We're here because of normal caching didn't work
    Attachment.save_as_file(attachment, image_id, "#{image_name}/#{format}")
    attachment
  end
  
  def Attachment.save_as_file(attachment, original_image_id, name)
    path = File.join(File.dirname(__FILE__), '/../../public/images/', original_image_id.to_s)
    FileUtils.mkdir_p path 
    File.open("#{path}/#{name}", "w") {|file|
      file.binmode
      file.write attachment.file
    }
  end

  def Attachment.store_rp_file(resource_property, options)
    # Should we first remove an old one?
    if (options.delete(:remove) != 'f')
      remove_thumbnails_and_cache(resource_property)
    end

    # Is file supplied?
    att = options[:value]
    if not file_provided?(att)
      options[:value] = options[:attachment] = nil
      return options
    end

    # Prepare new or replace an existing attachment
    remove_thumbnails_and_cache(resource_property) # remove old thumbnails if exist
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

  def Attachment.create_thumbnails_and_apply_geometry_and_cache(resource_property)
    # Format of geometry string:
    # myself:geom;thumb1:geom;...
    geometry = {}
    geometry_string = resource_property.property.geometry rescue ""
    geometry_string.scan(/(\w+):([\w%!><]+)/) { |key, value|
      geometry[key] = value
    }
    if geometry.empty? || ! geometry.has_key?('myself')
      # Save 'self' as an exact copy of an original image
      geometry['myself'] = '100%x100%'
    end
    
    attachment = resource_property.attachment
    Attachment.save_as_file(attachment, attachment.id, attachment.filename)
    ext = File.extname(attachment.filename)
    geometry.each { |name, geom|
      th = attachment.resize(geom, name)
      attachment.thumbnails << th
      Attachment.save_as_file(th, attachment.id, th.filename + ext)
    }
    attachment.save!
  end

  # Replace images upon geometry change
  def Attachment.update_thumbnails(property)
    ResourceProperty.find(:all, :conditions => ["property_id = ?", property.id]).each{ |rp|
      remove_thumbnails_and_cache(rp)
      if rp.attachment
        rp.resource.save
      end
    }
  end
  
  def Attachment.delete_file(original_image_id, name, delete_all = false)
    begin
      path = File.join(File.dirname(__FILE__), '/../../public/images/', original_image_id.to_s)
      Dir.glob(path + "/#{delete_all ? '*' : name}.*") { |filename|
        File.delete(filename)
      }
      Dir.delete(path) if name == 'original'
    rescue
    end
  end
  
  def is_image?
    mime_type =~ /^image/
  end

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
    thumb
  end

  def has_thumbnails?
    self.thumbnails.size > 0
  end

 def Attachment.remove_thumbnails_and_cache(resource_property)
  return if ! (resource_property && resource_property.attachment) or ! resource_property.attachment.is_image?

  Attachment.delete_file(resource_property.attachment.id, 'original', true)

  resource_property.attachment.thumbnails.each {|thumb|
    thumb.destroy
  }
  if resource_property.attachment.myself
    resource_property.attachment.myself.destroy
  end
end
  
  private

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
