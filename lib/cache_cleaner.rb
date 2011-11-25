module CacheCleaner
  
  class RSSCacheCleanJob < Struct.new(:nodes)
    def perform
      AuthenticationModel.cron_manager_user_login
      Base.clean_feed_cache(nodes.to_a)
    end
  end

  class RSSCacheCreateJob < Struct.new(:nodes)
    def perform
      AuthenticationModel.cron_manager_user_login
      Base.create_feed_cache(nodes.to_a)
    end
  end

  class Base

    require 'open-uri'
    require 'cgi'
  
    def self.clean_page_cache(nodes)
      nodes.each_with_index{|node, index|
        url, clean_url = get_url_by_tree_node(node)
        Logger.new(STDOUT).debug "#{"%02d" % index} Refresh URL #{clean_url}"
        begin
          Rails.cache.delete(node.id.to_s)
          open(CGI.escapeHTML(url))
        rescue Exception => ex
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% FAILURE #{ex}"
          # exit(1)
        end
      }
    end

    def self.clean_feed_cache(nodes)
      Logger.new(STDOUT).debug "############################ enter function clean_feed_cache. nodes=#{nodes}"
      return unless nodes
      unless nodes.is_a?(Array)
        nodes = [nodes]
      end
      nodes_to_check = 
        ([nodes] + nodes.inject([]){ |list, element|  
          list << element.ancestors
        }).flatten.map{|e| e.id}.uniq
      Logger.new(STDOUT).debug "############################ nodes to check:#{nodes_to_check.join(',')}"
      feeds = Feed.find(:all, :select => 'id, section_id, feed_type', :conditions => {:section_id => nodes_to_check})
      Logger.new(STDOUT).debug "############################ feeds to clean:#{feeds.map{|e|e.id}.join(',')}"
      feeds.each{ |feed| 
        begin
          url, clean_url = get_url_by_tree_node(feed.tree_node)
          clean_url += "/feed.#{feed.feed_type}"
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% Removing feed #{clean_url}"
          feed.delete
        rescue Exception => e
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% FAILURE #{e} for feed #{clean_url}"
          # exit(1)
        end
      }
      Logger.new(STDOUT).debug "############################ feeds cleaned:#{feeds.map{|e|e.id}.join(',')}"
    end

    def self.create_feed_cache(nodes)
      Logger.new(STDOUT).debug "############################ enter function create_feed_cache. nodes=#{nodes}"
      return unless nodes
      unless nodes.is_a?(Array)
        nodes = [nodes]
      end
      nodes_to_check = 
        ([nodes] + nodes.inject([]){ |list, element|  
          list << element.ancestors
        }).flatten.map{|e| e.id}.uniq
      Logger.new(STDOUT).debug "############################ Feeds to create:#{nodes_to_check.join(',')}"
      nodes_to_check.each{ |node_id| 
        begin
	  node = TreeNode.find(node_id)
          url, clean_url = get_url_by_tree_node(node)
	  now = 'rss'
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% Refresh feed #{clean_url}/feed.rss"
          url = CGI.escapeHTML(url)
          open(url + "/feed.rss")
	  now = 'atom'
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% Refresh feed #{clean_url}/feed.atom"
          open(url + "/feed.atom")
        rescue Exception => e
          Logger.new(STDOUT).debug "%%%%%%%%%%%%%%%%%%%%%%%%%% FAILURE #{e} for feed #{clean_url}/feed.#{now}"
          # exit(1)
        end
      }
      Logger.new(STDOUT).debug "############################ Feeds created:#{nodes_to_check.join(',')}"
    end
   
    def self.get_url_by_tree_node(node)
      base_url = $config_manager.appl_settings[:sweep_url]
      if node.resource.resource_type.hrid.eql?('website')
        website = Website.find_by_entry_point_id(node.resource.id)
        prefix = website.use_homepage_without_prefix ? '' : '/' + website.prefix
        url = "#{base_url}#{prefix}"
      else
        root_node = TreeNode.find_first_parent_of_type_website(node.parent_id)
        website = Website.find_by_entry_point_id(root_node.resource.id)
        prefix = website.prefix
        url = "#{base_url}/#{prefix}/#{node.permalink}"
      end
      [URI.escape(url), url]
    end
  end
end
