require 'pp'

namespace :access do
  desc "Set permissions for tree node access (and for all its children). Parameters:"
  "  node_id=<ID of node to start from"
  "  access_type=<0-Forbidden, 1-Reading, 2-Editing 3-Managing>"
  "  group=<group ID>"
  task :for_node, [:node_id, :access_type, :group] => [:login] do |t, args|
    tree_node_id = args[:node_id] || nil
    access_type = args[:access_type] || nil
    group_id = args[:group] || nil

    # Validations
    if tree_node_id.nil? || access_type.nil? || group_id.nil?
      puts "You have to supply all three parameters\n\n"
      puts "  node_id=<number of node to start from>"
      puts "  access_type=<0-Forbidden, 1-Reading, 2-Editing 3-Managing>"
      puts "  group=<group number>"
      raise Exception.new 'Not enough parameters'
    end

    tree_node = TreeNode.find(tree_node_id) rescue nil
    raise "Tree_node #{node_id} not found." if tree_node.nil?

    tree_node_ac_rights = TreeNodeAcRight.new({'group_id' => group_id, 'ac_type' => access_type})
    tree_node_ac_rights.tree_node_id = tree_node_id

    tree_node_ac_rights.save
  end

end

task(:login => :environment) do
  ActiveRecord::Migration.migration_login
end
