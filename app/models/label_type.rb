class LabelType < ActiveRecord::Base
  belongs_to :user
  has_many :label_type_descs
  has_many :labels

  def LabelType.select_all_types
    find_all().map { |lt| [lt.hrid, lt.id] }.sort
  end

  # Find labelType by ID (string)
  def LabelType.getById(id)
    find_by_id(id)
  end
end
