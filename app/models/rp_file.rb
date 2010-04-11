class RpFile < ResourceProperty	

  attr_reader :remove

  def remove=(value)
    if (value == 't' || value == 'true')
      # In the case of replacement do not remove attachment,
      # because it is already a new one (value= was already called)
      if (attributes['file_value'] == nil)
        Attachment.remove_thumbnails_and_cache(self)
        self.save!
        return
      end
    end

  end

  validates_length_of :file_content, :as => :attachment, :maximum => 5.megabytes

  def original
    attachment
  end

  def myself
    attachment.myself
  end

  def thumbnails
    (attachment && attachment.thumbnails) || []
  end

  def mime_type
    (attachment && attachment.mime_type) || ''
  end

  def file_content
    (attachment && attachment.file_content) || ''
  end

  def value
    #puts on new records the default code if exists
    super('file_value')
  end

  def value=(input)
    Attachment.remove_thumbnails_and_cache(self)
    Attachment.store_new_file(self, input)
    Attachment.create_thumbnails_and_apply_geometry_and_cache(self)
    write_attribute('file_value', input)
  end

	# This method is for reading values. DO NOT use for editing
  def get_value
    read_attribute('file_value')
  end

end
