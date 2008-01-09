class TreeNode < ActiveRecord::Base
	belongs_to :resource
	acts_as_tree :order => "position"
	acts_as_list
	

	def self.get_subtree(parent = 0, depth = 0)
		find_by_sql "SELECT  a.* FROM  connectby('tree_nodes', 'id', 'parent_id', 'position',  '#{parent}', #{depth}) 
								 AS t(id int, parent_id int, level integer, position int) 
								 join tree_nodes a on (a.id = t.id) ORDER BY  t.position"
	end
end
