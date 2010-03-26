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
  
  def Attachment.get_short_attachment(resource_property_id)
    find(:first, {:select=>'id, filename', :conditions => ["resource_property_id = ?", resource_property_id]})
  end

  require 'uri'
  def Attachment.get_dims_attachment(resource_property_id, name, path)
    image = find(:first, {:conditions => ["resource_property_id = ?", resource_property_id]})
		if image
			thumb = image.thumbnails.detect{|th| th.filename.eql?(name)}
			if thumb == nil
				thumb = "public/#{URI.parse(path).path}"
				img = MiniMagick::Image.from_file(thumb) rescue {:width => 0, :height =>0}
			else
				img = MiniMagick::Image.from_blob(thumb.file) rescue {:width => 0, :height =>0}
			end
			[ img[:width], img[:height] ]
		else
			[ 0, 0 ]
    end
  end

  def Attachment.get_image(image_id, image_name, format)
    split = image_name.split("_", 2)
    _image_id   = split[0]
    _image_name = split[1]
    attachment = find(:first, :conditions => ["id = ?", _image_id])
    return nil unless attachment

    case _image_name
    when 'original'
      attachment = attachment.resource_property.original
    when 'myself'
      attachment = attachment.myself || attachment.resource_property.original
    else
      if thumbnail = attachment.thumbnails.detect{|th| th.filename.eql?(_image_name)}
        attachment = thumbnail
      end
    end

    # We're here because of normal caching didn't work
    Attachment.save_as_file(attachment, _image_id, "#{_image_name}.#{format}")
    attachment
  end
  
  def Attachment.save_as_file(attachment, original_image_id, name)
    path = File.join(File.dirname(__FILE__), '/../../public/images/attachments/', (original_image_id.to_i % 100).to_s)
    FileUtils.mkdir_p path 
    File.open("#{path}/#{original_image_id}_#{name}", "w") {|file|
      file.binmode
      file.write attachment.file
    }
  end

  def Attachment.store_new_file(resource_property, file)
    # Prepare new or replace an existing attachment
    attachment = Attachment.new
    attachment.size = file.length
    attachment.filename = sanitize_filename(file.original_filename)
    attachment.file = file.read
    attachment.mime_type = file.content_type.chomp
    attachment.md5 = Digest::MD5.hexdigest(attachment.file)
    attachment.save!

    # Is it valid?
    resource_property.attachment = attachment if attachment.valid?
  end

  # We don't support both 'remove file' and 'new file' options
  # 'Remove' always has precedence

  # Returns: options
  def Attachment.store_rp_file(resource_property, options)
    #    return options if resource_property.nil? ZZZ What is it good for?
    
    # Should we first remove an old one?
    remove = options.delete(:remove)
    if (!remove.empty? && remove != 'f')
      remove_thumbnails_and_cache(resource_property)
      options[:value] = options[:attachment] = nil
      return options
    end

    # Is file supplied?
    att = options[:value]
    if not file_provided?(att)
      options[:attachment] = resource_property ? resource_property.attachment : nil
      options[:value] = nil
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
    geometry_string = resource_property.property.geometry rescue ''
    geometry_string = '' if geometry_string.nil?
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
    #    attachment.save!
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
      path = File.join(File.dirname(__FILE__), '/../../public/images/attachments/', (original_image_id.to_i % 100).to_s)
      if delete_all
        Dir.glob(path + "/*.*") { |filename|
          File.delete(filename)
        }
      else
        File.delete(path + "/" + original_image_id.to_s + "_" + name)
      end
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
    return unless resource_property && resource_property.attachment
    return unless resource_property.attachment.is_image?

    attachment = resource_property.attachment
    ext = File.extname(attachment.filename)
    
    Attachment.delete_file(attachment.id, attachment.filename)
    
    # Format of geometry string:
    # myself:geom;thumb1:geom;...
    geometry = {}
    geometry_string = resource_property.property.geometry rescue ''
    geometry_string = '' if geometry_string.nil?
    geometry_string.scan(/(\w+):([\w%!><]+)/) { |key, value|
      geometry[key] = value
    }
    
    geometry.each { |name, geom|
      Attachment.delete_file(attachment.id, name + ext)
    }
    
    resource_property.attachment.thumbnails.each {|thumb|
      thumb.destroy
    }
    if resource_property.attachment.myself
      Attachment.delete_file(attachment.id, 'myself' + ext)
      resource_property.attachment.myself.destroy
    end
    
    resource_property.attachment.destroy
    resource_property.save
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
