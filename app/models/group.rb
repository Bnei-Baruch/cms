class Group < ActiveRecord::Base
  validates_presence_of     :groupname
  validates_uniqueness_of   :groupname
  
  has_and_belongs_to_many :users
  has_many :tree_node_ac_rights, :dependent => :destroy
  
  def validate_on_update
    errors.add_to_base("The group cann't be edit. It is system group.") if is_system_group==true
  end
  
  def before_destroy
    if is_system_group==true
      errors.add_to_base("The group cann't be deleted. It is system group.") 
      false
    end
  end
end
