class CmsSweeper < ActionController::Caching::Sweeper
#  observe Resource, ResourceProperty, Property, ResourceType, TreeNode,
#    Attachment, List, ListValue, Website
  #
  #  Plan:
  #  V1 - to remove as less as possible
  #  V2 - to add DRb
  #  V3 - to move attachments to paperclip + to remove as less as possible due to attachment's change/removal
  #
  #  On TreeNode resides Resource.
  #  Resource has its content fields as ResourceProperty.
  #  Type of each ResourceProperty is Property.
  #
  #  Table                Action on change
  #  Resource               find the TreeNodes that use this Resource and for each TreeNode do as described below for TreeNodes
  #  ResourceProperty       to find Resource and TreeNode
  #  TreeNode               remove only this TreeNode and all TreeNodes that are using it (stored as result of tracking during render)
  #
  #  Property               remove all
  #  ResourceType           remove all
  #  Attachment             V1: to ignore (check); V2: to find Resource and TreeNode (to check whether it comes together with ResourceProperty)
  #  List                   remove all
  #  ListValue              remove all
  #  Website                remove all
  #
  #  Sweeper ignores changes in Resources and ResourceProperties.
  #  When TreeNode is changed:
  #  1. Get its Resource and find out all TreeNodes with this Resource on them
  #  2. For each of these TreeNodes find in table their parent node (i.e. the node that is Page) and clean its cache
  #  Note: the table should include Page node as its child to reduce looking up overhead

  def after_save(record)
    Feed.delete_all
    self.class::sweep(record)
  end
  
  def after_destroy(record)
    Feed.delete_all
    self.class::sweep(record)
  end

  require 'logger'
  def self.sweep(record)
    nodes = nil
    case record.class.to_s
    when /#{RpBoolean.to_s}|#{RpFile.to_s}|#{RpString.to_s}|#{RpDate.to_s}|#{RpList.to_s}|#{RpNumber.to_s}|#{RpPlaintext.to_s}|#{RpText.to_s}|#{RpTimestamp.to_s}/
      #      return unless record.changed?
      #      Logger.new(STDOUT).debug "############################ Sweep #{record.class} -- IGNORE"
    when /#{Resource.to_s}/
      Logger.new(STDOUT).debug "############################ Sweep #{record.class} with ID #{record.id} -- ACTION"
      #  1. Get its Resource and find out all TreeNodes with this Resource on them
      #  2. For each of these TreeNodes find in table their parent node (i.e. the node that is Page) and clean its cache
      #      nodes = CacheMap.find_all_by_child(TreeNode.find_all_by_resource_id(record.id).map{|node| node.id}).map{|node| node.parent}.uniq
      
      nodes = CacheMap.find_by_sql("BEGIN WORK;LOCK TABLE cache_maps IN SHARE ROW EXCLUSIVE MODE;SELECT parent FROM cache_maps WHERE child IN (SELECT id FROM tree_nodes WHERE resource_id = #{record.id})").map{|node| node.parent}.uniq
      #ZZZ!!! RESTORE THIS LINE !!!      CacheMap.find_by_sql("DELETE FROM cache_maps WHERE parent IN (#{nodes.join(',')})") if nodes && !nodes.empty?
      CacheMap.find_by_sql('COMMIT WORK;')
    when /#{TreeNode.to_s}/
      Logger.new(STDOUT).debug "############################ Sweep #{record.resource.class} with ID #{record.id} -- ACTION"
      #  1. Get its Resource and find out all TreeNodes with this Resource on them
      #  2. For each of these TreeNodes find in table their parent node (i.e. the node that is Page) and clean its cache
      #      nodes = CacheMap.find_all_by_child(TreeNode.find_all_by_resource_id(record.resource.id).map{|node| node.id}).map{|node| node.parent}.uniq
      nodes = CacheMap.find_by_sql("BEGIN WORK;LOCK TABLE cache_maps IN SHARE ROW EXCLUSIVE MODE;SELECT parent FROM cache_maps WHERE child IN (SELECT id FROM tree_nodes WHERE resource_id = #{record.resource.id})").map{|node| node.parent}.uniq
      CacheMap.find_by_sql("DELETE FROM cache_maps WHERE parent IN (#{nodes.join(',')})") if nodes && !nodes.empty?
      CacheMap.find_by_sql('COMMIT WORK;')
    when /#{Attachment.to_s}/
      #      Logger.new(STDOUT).debug "############################ Sweep #{record.class} -- IGNORE for now..."
    else
      Logger.new(STDOUT).debug "############################ Sweep #{record.class} -- REMOVE ALL"
      # Clean up database
      find_by_sql "BEGIN WORK;LOCK TABLE cache_maps IN SHARE ROW EXCLUSIVE MODE;DELETE FROM cache_maps;COMMIT WORK;"
      # Remove cache
      FileUtils.rm_rf(Dir['tmp/cache/[^.]*'])
    end

    # There are nodes to refresh
    return unless nodes
    Logger.new(STDOUT).debug "############################     We have to refresh nodes #{nodes.join(',')}"
    nodes.each{|node|
      FileUtils.rm_f(Dir["tmp/cache/tree_nodes/#{node}-*"])
      my_port = ':4000' #It should be hardcoded somewhere...
      node = TreeNode.find_by_id(node)
      if node.resource.resource_type.hrid.eql?('website')
        root_node = node
        website = Website.find_by_entry_point_id(root_node.resource.id)
        url = "#{website.domain}#{my_port}/"
      else
        root_node = TreeNode.find_first_parent_of_type_website(node.parent_id)
        website = Website.find_by_entry_point_id(root_node.resource.id)
        url = "#{website.domain}#{my_port}/#{website.prefix}/#{node.permalink}"
      end
      Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% Refresh URL #{url}"
      open(url)
    }
  end
  
end
