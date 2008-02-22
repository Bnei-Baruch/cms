class TreeNodeAcRights < ActiveRecord::Base
  belongs_to :tree_node
  belongs_to :group
  
  validates_uniqueness_of   :group_id , :scope =>[:tree_node_id, :ac_type]
end
