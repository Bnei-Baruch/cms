class TreeNode < ActiveRecord::Base
  belongs_to :resource
  acts_as_tree :order => "position"
  acts_as_list
  
  attr_accessor :has_url
  attr_accessor :ac_type

  # The has_url virtual variable is passed to when requesting for resource edit/create
  # if true than on the resource edit/create of this tree_node will show permalink text field
  # Embedded resources won't have permalink
  def has_url
    if self.new_record?
      ActiveRecord::ConnectionAdapters::Column.value_to_boolean(@has_url)
    else
      not permalink.blank?
    end
  end
  
  def after_find
    self.ac_type ||= AuthenticationModel.get_ac_type_to_tree_node(self.id)
    self.ac_type
  end 

  def self.get_subtree(parent = 0, depth = 0)
    find_by_sql "SELECT  a.* FROM  connectby('tree_nodes', 'id', 'parent_id', 'position',  '#{parent}', #{depth}) 
    AS t(id int, parent_id int, level integer, position int) 
    join tree_nodes a on (a.id = t.id) ORDER BY  t.position"
  end

  class << self
    alias :old_find_by_sql :find_by_sql
  end
  def self.find_by_sql(arg)
    output=self.old_find_by_sql(arg)
    #if output.respond_to?:entry and !(output.entry.kind_of? Array)
    #    output.entry=[output.entry]
    #end
    output
  end

  protected
  
  def TreeNode.find_first_parent_of_type_website(parent_id)
    node = TreeNode.find(:first, :conditions => ["parent_id = ?", parent_id])
    while node && !node.resource.resource_type.hrid.eql?('website')
      node = node.parent 
    end
    node
  end
end
