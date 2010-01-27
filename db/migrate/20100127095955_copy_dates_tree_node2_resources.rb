class CopyDatesTreeNode2Resources < ActiveRecord::Migration
  def self.up
    migration_login

    TreeNode.find(:all).each_with_index { |node, index|
      puts "#{index}...\r" if index % 100 == 0

      execute <<-SQL
        UPDATE resources SET created_at='#{node.created_at}', updated_at='#{node.updated_at}'
        WHERE id = #{node.resource.id}
      SQL
    }
  end

  def self.down
  end
end
