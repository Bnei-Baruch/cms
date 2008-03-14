class Group < ActiveRecord::Base
  validates_presence_of     :groupname
  validates_uniqueness_of   :groupname
  
  has_and_belongs_to_many :users
  has_many :tree_node_ac_rights, :dependent => :destroy
end
