class RpFile < ResourceProperty	

  validates_length_of :file, :as => :attachment, :maximum => 5.megabytes

  def original
    attachment
  end

  def myself
    attachment.myself
  end

  def thumbnails
    attachment.thumbnails
  end

  def mime_type
    (attachment && attachment.mime_type) || ''
  end

  def file
    (attachment && attachment.file) || ''
  end

  def value
    #puts on new records the default code if exists
    super('file_value')
  end

  def value=(input)
    write_attribute('file_value', input)
  end

end
