class Label < ActiveRecord::Base
  belongs_to :label_type
	has_and_belongs_to_many :items

	validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  protected

  def validate
    l = Label.find_by_hrid(self.hrid)
    return unless l
    if !self.id || self.id!=l.id
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

end