class PageMap < ActiveRecord::Base
  require 'ar-extensions'
  require 'ar-extensions/adapters/postgresql'
  require 'ar-extensions/import/postgresql'

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
      column_names = %W{ parent_id child_id }
      values = @tree_nodes_list.uniq.map{|node| [parent, node]}
      PageMap.import(column_names, values, :validate => false) if PageMap.count(:all, :conditions => ['parent_id = ?', parent]) == 0

      @tree_nodes_list = []
    end

    private
    attr_accessor :tree_nodes_list
  end
  
  @tree_nodes_list = []
end
