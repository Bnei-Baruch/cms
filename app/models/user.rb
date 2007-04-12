class User < ActiveRecord::Base
  has_many :label_types
  has_many :tree_nodes
  has_many :labels
end
