# This module is used by Cron 
# Usage: ruby script/runner 'CronManager.read_and_save_rss' -e development

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'timeout'

class CronManager
  
  def self.read_and_save_rss 
   
    cron_manager_user_login
    websites = Website.find(:all, :conditions => ["entry_point_id<>?", 0])
    
    websites.each do |website|
      website_tree_node = TreeNode.find(:first, :conditions => ["resource_id = ?", website.entry_point_id])

      if (website_tree_node)
        tree_nodes = TreeNode.get_subtree(
          :parent => website_tree_node.id, 
          :resource_type_hrids => ['rss']
        )

        tree_nodes.each do |tree_node|
          read_and_save_node_rss(tree_node)
        end
      end
    end
  end
  
  def self.read_and_save_node_rss(tree_node)
    content = ''
    
    retries = 42
    begin
      Timeout::timeout(s){
        open((tree_node.resource.properties('url')).get_value) { |f|
          content = f.read
        }
      }
    
    rescue Timeout::Error
      retries -= 1
      if retries > 0
        sleep 0.42 and retries
      else
        raise
      end
    end

    range = Range.new(0, (tree_node.resource.properties('number_of_items')).get_value, true)
    data = YAML.dump(RSS::Parser.parse(content, false).items[range])
    property = tree_node.resource.properties('items')
    property.update_attributes(:text_value => data)
  end
  
  private
  
  def self.cron_manager_user_login

    msession = Hash.new
    username = $config_manager.appl_settings[:cron_manager_login_user][:username]
    password = $config_manager.appl_settings[:cron_manager_login_user][:password]
    user = User.authenticate(username, password)
    if user
      msession[:user_id] = user.id
      msession[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
    else
      logger.error("Rss Reader user is not defined or banned. Access denied.")
      raise "Access denied for Rss Reader user."
    end

    Thread.current[:session] = msession
  end
  
end 


