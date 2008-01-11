class RpFile < ResourceProperty	

  validates_format_of :mime_type, :as => :attachment,
    :with => /^image/,
    :message => '-- you can only upload pictures'

  validates_length_of :file, :as => :attachment, :in => 1.byte..1.megabyte

  attr_accessor :remove
  
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
