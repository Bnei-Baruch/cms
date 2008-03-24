require "authentication_model"

class TreeNodeAcRight < ActiveRecord::Base
  belongs_to :tree_node
  belongs_to :group
  
  validates_uniqueness_of   :group_id , :scope =>[:tree_node_id]
  
  validates_inclusion_of :ac_type, :in => AuthenticationModel::NODE_AC_TYPES.map {|key, value| key}
  
  def get_tree_node
   TreeNode.find_as_admin(tree_node_id)
  end
  
  def after_save
    #copy parent permission to the new tree_node
    AuthenticationModel.copy_tree_node_permission_to_child(self)
  end
  
  def before_destroy
    #delete tree_node_rights to child
    AuthenticationModel.delete_tree_node_permission_to_child(self)
  end
  
  def ac_type_str
  # NODE_AC_TYPES.detect {|disp, value| value.to_s == :ac_type.to_s }
  # return res.first 
  # res= NODE_AC_TYPES.rassoc(:ac_type)
  #NODE_AC_TYPES.rassoc(2)
  # res.first
    AuthenticationModel::NODE_AC_TYPES[ac_type]
  end
  
end
