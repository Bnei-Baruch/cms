class Label < ActiveRecord::Base
  has_and_belongs_to_many :tree_nodes
  belongs_to :user
  has_many :label_descs
  belongs_to :label_type
  has_many :languages
end
