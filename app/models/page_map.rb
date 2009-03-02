class PageMap < ActiveRecord::Base
  class << self;

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
      return if @tree_nodes_list.empty?

      # Mass update...
      parent = tree_nodes_list[0]
      if PageMap.count(:all, :conditions => ['parent_id = ?', parent]) == 0
        PageMap.find_by_sql 'PREPARE update_PM (int, int) AS INSERT INTO page_maps(parent_id, child_id) VALUES($1, $2);' rescue ''
        @tree_nodes_list.uniq.each {|node|
          PageMap.find_by_sql "EXECUTE update_PM (#{parent},#{node});"
        }
        PageMap.find_by_sql 'DEALLOCATE update_PM;' rescue ''
      end

      @tree_nodes_list = []
    end

    private
    attr_accessor :tree_nodes_list
  end
  
  @tree_nodes_list = []
end
