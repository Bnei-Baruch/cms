class PageMap < ActiveRecord::Base
  class << self;

    # Remove dependent caches
    def remove_dependent_caches(tree_node)
      PageMap.find_all_by_child_id(tree_node.id).map {|map| TreeNode.find(map.parent_id) }.each{ |node|
        key = node.this_cache_key
        Rails.cache.delete(key)if Rails.cache.exist?(key)
      }
    end

    def reset_tree_nodes_list
      @tree_nodes_list = []
    end

    def print_tree_nodes_list
      @tree_nodes_list.uniq.join(',')
    end

    def add_to_tree_nodes_list(id)
      @tree_nodes_list << id
    end

    def save_tree_nodes_list
      # logger.error "save_tree_nodes_list: #{@tree_nodes_list.length} items"
      return if @tree_nodes_list.empty?

      # Mass update...
      parent = tree_nodes_list[0]
      homepage = Thread.current[:presenter].website_node.id
      unless parent == homepage
        tree_nodes_list.delete_if {|x| x == homepage}
      end
      # logger.error "save_tree_nodes_list will remove from DB with parent_id = #{parent}"
      PageMap.find_by_sql "START TRANSACTION"
      PageMap.find_by_sql "DELETE FROM page_maps WHERE parent_id = #{parent}"
      # logger.error "save_tree_nodes_list will update DB"
      PageMap.find_by_sql 'PREPARE update_PM (int, int) AS INSERT INTO page_maps(parent_id, child_id) VALUES($1, $2);' rescue ''
      @tree_nodes_list.uniq.each {|node|
        PageMap.find_by_sql "EXECUTE update_PM (#{parent},#{node});"
      }
      PageMap.find_by_sql 'DEALLOCATE update_PM;' rescue ''

      PageMap.find_by_sql "COMMIT"
      # logger.error "save_tree_nodes_list hopefully updated DB"
      @tree_nodes_list = []
    end

    private
    attr_accessor :tree_nodes_list
  end
  
  @tree_nodes_list = []
end
