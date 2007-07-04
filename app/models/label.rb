class Label < ActiveRecord::Base
  belongs_to :label_type
 
  has_many :descriptions, :dependent => :destroy
  has_many :items, :through => :descriptions # , :before_add => :check_uniq_item_labels


  #	validates_presence_of :hrid
  #validates_uniqueness_of :hrid - moved to validate

  #  protected

  #  def validate
  #    l = Label.find_by_hrid(self.hrid)
  #    return unless l
  #    if !self.id || self.id!=l.id
  #      errors.add(:hrid, " '#{hrid}' is already being used" )
  #    end
  #  end

end