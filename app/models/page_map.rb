class PageMap < ActiveRecord::Base

  def self.logger
    @logger ||= Logger.new("#{RAILS_ROOT}/log/cache_clean.log", 10, 5242880)
  end

  def self.remove_cache(tree_node, is_homepage = false)
    if is_homepage
      # Special case - clear everything
      path = "#{Rails.root}/tmp/cache/#{tree_node.class.model_name.cache_key}/*"
      Dir[path].each do |file|
        FileUtils.rm_rf file, :verbose => true
      end

    else
      key = tree_node.this_cache_key
      Rails.cache.delete(key) if Rails.cache.exist?(key)
    end
  end

  # Remove dependent caches
  def self.remove_dependent_caches(tree_node)
        #time = Time.new
        #logger.debug "#{time} START remove_dependent_caches"
    # PageMap.find_by_sql "START TRANSACTION"
    #PageMap.find_by_sql 'PREPARE delete_PM (int) AS DELETE FROM page_maps WHERE parent_id = $1' rescue ''
        #logger.debug "#{time} after PREPARE"
    tid = tree_node.id
    #    logger.debug "#{time} ACT TreeNode.id = #{tid}"
    [
      # This node is child of or parent of...
      PageMap.find(:all, :conditions => ['child_id = ? OR parent_id = ?', tid, tid]) +
        # This is a new node and it was attached to...
      if (tree_node.parent) then
        pid = tree_node.parent.id
        PageMap.find(:all, :conditions => ['child_id = ? OR parent_id = ?', pid, pid])
      else
        []
      end
    ].compact.flatten.uniq.map { |map|
      TreeNode.find(map.parent_id)
    }.each { |node|
      key = node.this_cache_key
      #logger.debug "#{time} ACT KEY = #{key}, #{Rails.cache.exist?(key) ? 'EXISTS' : 'NOT EXISTS'}; node.id = #{node.id}"
      Rails.cache.delete(key) if Rails.cache.exist?(key)
      PageMap.find_by_sql "DELETE FROM page_maps WHERE parent_id = #{node.id}"
      #PageMap.find_by_sql "EXECUTE delete_PM (#{node.id})"
    }
        #logger.debug "#{time} after DEALLOCATE"
    #PageMap.find_by_sql 'DEALLOCATE delete_PM'
    #ZZZ This disables Rails to ROLLBACK...    PageMap.find_by_sql "COMMIT"

    #Will clean the rss cache of the tree node in delayed job - add it to the queue
    begin
      #Feed.find_by_sql('DELETE FROM feeds')
      Delayed::Job.enqueue CacheCleaner::RSSCacheCleanJob.new(tree_node)
      #ZZZ Delayed::Job.enqueue CacheCleaner::RSSCacheCreateJob.new(tree_node)
    rescue
    end
    # CacheCleaner::Base.clean_feed_cache(tree_node)
    #    logger.debug "#{time} FINISH remove_dependent_caches"
  end

  def self.remove_dependent_caches_by_resource(resource)
    #    time = Time.new
    #    logger.debug "#{time} START remove_dependent_caches_by_resource"
    TreeNode.find_all_by_resource_id(resource.id).each { |node|
      remove_dependent_caches(node)
    }
    #    logger.debug "#{time} FINISH remove_dependent_caches_by_resource"
  end

  def self.reset_tree_nodes_list
    @tree_nodes_list = []
  end

  def self.print_tree_nodes_list
    @tree_nodes_list.uniq.join(',')
  end

  def self.add_to_tree_nodes_list(id)
    @tree_nodes_list << id
  end

  def self.save_tree_nodes_list
    # logger.error "save_tree_nodes_list: #{@tree_nodes_list.length} items"
    return if @tree_nodes_list.empty?

    # Mass update...
    parent = tree_nodes_list[0]
    homepage = Thread.current[:presenter].website_node.id
    unless parent == homepage
      tree_nodes_list.delete_if { |x| x == homepage }
    end
    # logger.error "save_tree_nodes_list will remove from DB with parent_id = #{parent}"
    PageMap.find_by_sql "START TRANSACTION"
    PageMap.find_by_sql "DELETE FROM page_maps WHERE parent_id = #{parent}"
    # logger.error "save_tree_nodes_list will update DB"
    PageMap.find_by_sql 'PREPARE update_PM (int, int) AS INSERT INTO page_maps(parent_id, child_id) VALUES($1, $2);' rescue ''
    @tree_nodes_list.uniq.each { |node|
      PageMap.find_by_sql "EXECUTE update_PM (#{parent},#{node});"
    }
    PageMap.find_by_sql 'DEALLOCATE update_PM;' rescue ''

    PageMap.find_by_sql "COMMIT"
    # logger.error "save_tree_nodes_list hopefully updated DB"
    @tree_nodes_list = []
  end

  class << self
    private
    attr_accessor :tree_nodes_list
  end


  @tree_nodes_list = []
end
