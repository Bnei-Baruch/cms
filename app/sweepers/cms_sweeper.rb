class CmsSweeper < ActionController::Caching::Sweeper
  observe Resource, ResourceProperty, Property, ResourceType, TreeNode,
    Attachment, List, ListValue, Website
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
    self.class::sweep(record)
  end
  
  def after_destroy(record)
    self.class::sweep(record)
  end

  #require 'logger'
  def self.sweep(record)
    #Logger.new(STDOUT).debug "Sweep record #{record.class}"
    FileUtils.rm_rf(Dir['tmp/cache/[^.]*']) rescue Errno::ENOENT
  end
  
end
