class Label < ActiveRecord::Base
  belongs_to :label_type

	validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  protected

  def validate
    if Label.find_by_hrid(hrid)
      errors.add(:hrid, " '#{hrid}' is already being used" )
    end
  end

end
