class CmsSweeper < ActionController::Caching::Sweeper
  observe Resource, ResourceProperty, Property, ResourceType, TreeNode,
    Attachment, List, ListValue, Website

  def after_save(record)
    self.class::sweep(record)
  end
  
  def after_destroy(record)
    self.class::sweep(record)
  end
          
  def self.sweep(record)
    FileUtils.rm_rf(Dir['tmp/cache/[^.]*']) rescue Errno::ENOENT
  end
end
