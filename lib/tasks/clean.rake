require 'pp'

namespace :clean do
	desc "Clean __ALL__ CMS caches"
	task(:all => :cache) do
    res = PageMap.find_by_sql "select cms_cache_outdated_pages_refresh(false) as cms_cache_outdated_pages_refresh"
    log res, 'cms_cache_outdated_pages_refresh'
    res = PageMap.find_by_sql "select cms_cache_resource_properties_refresh(true) as cms_cache_resource_properties_refresh"
    log res, 'cms_cache_resource_properties_refresh'
    res = PageMap.find_by_sql "select cms_cache_tree_node_ac_rights_refresh(true) as cms_cache_tree_node_ac_rights_refresh"
    log res, 'cms_cache_tree_node_ac_rights_refresh'
  end
  
  desc "Clean CMS caches"
  task(:cache => :environment) do
    
    # 1. remove files from tmp/cache/tree_nodes
    res = FileUtils.rm_r(Dir['tmp/cache/tree_nodes/'])
    log res, 'TreeNodes'

    # 2. clear tables - page_maps and cms_cache_outdated_pages
    res = PageMap.find_by_sql "DELETE FROM page_maps"
    log res, 'PageMaps'
    res = PageMap.find_by_sql "DELETE FROM cms_cache_outdated_pages"
    log res, 'cms_cache_outdated_pages'
    
    # 3. clean JS and CSS cached files
    res = FileUtils.rm(Dir['public/javascripts/cache_*.js'])
    log res, 'Cached JS'
    res = FileUtils.rm(Dir['public/stylesheets/cache_*.css'])
    log res, 'Cached CSS'
    
    # 4. clean DB properties and tree nodes ac rights cache
    res = ActiveRecord::Base.connection.execute("select cms_cache_resource_properties_refresh(true) as cms_cache_resource_properties_refresh")
    log res, 'cleaned resource properties cache'            
    res = ActiveRecord::Base.connection.execute("select cms_cache_tree_node_ac_rights_refresh(true) as cms_cache_tree_node_ac_rights_refresh")
    log res, 'cleaned tree nodes ac rights cache'
  end
end

def log(res, title = '')
  trace = Rake.application.options.trace
  return unless trace

  print "#{title}: "
  res ? (print "--\n") : (pp res)
end