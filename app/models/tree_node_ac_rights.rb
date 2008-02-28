class TreeNodeAcRights < ActiveRecord::Base
  belongs_to :tree_node
  belongs_to :group
  
  validates_uniqueness_of   :group_id , :scope =>[:tree_node_id]
  
  NODE_AC_TYPES = {
    #  Displayed        stored in db
    0 => "Forbidden",
    1 => "Read",
    2 => "Edit",
    3 => "Administer"
  }
   validates_inclusion_of :ac_type, :in => NODE_AC_TYPES.map {|key, value| key}
   
  def ac_type_str
  # NODE_AC_TYPES.detect {|disp, value| value.to_s == :ac_type.to_s }
  # return res.first 
  # res= NODE_AC_TYPES.rassoc(:ac_type)
  #NODE_AC_TYPES.rassoc(2)
  # res.first
    NODE_AC_TYPES[ac_type]
  end
end
