class Language < ActiveRecord::Base
  belongs_to :label, :foreign_key => :label_id, :class_name => "TextLabel", :dependent => :destroy
  has_many :label_type_descs

  validates_presence_of :abbr
  validates_uniqueness_of :abbr
  validates_length_of :abbr, :is => 3

  protected

  def after_destroy
    self.label.destroy
  end
end
