class TreeNodeAcRights < ActiveRecord::Base
  belongs_to :tree_node
  belongs_to :group
  
  validates_uniqueness_of   :group_id , :scope =>[:tree_node_id]
  
  NODE_AC_TYPES = [
    #  Displayed        stored in db
    [ "Forbidden",          0 ],
    [ "Read",    1],
    [ "Edit", 2 ],
    [ "Administer", 3]
  ]
   validates_inclusion_of :ac_type, :in => NODE_AC_TYPES.map {|disp, value| value}
end
