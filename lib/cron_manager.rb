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
          :resource_type_hrids => ['rss', 'media_rss']
        )

        tree_nodes.each do |tree_node|
          if tree_node.resource.resource_type.hrid == 'rss'
            read_and_save_node_rss(tree_node)
          else
            read_and_save_node_media_rss(tree_node, get_language(website))
          end
        end
      end
    end
  end
  
  def self.read_and_save_node_rss(tree_node)
    content = ''
    
    retries = 2
    begin
      Timeout::timeout(25){
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
    range = Range.new(0, tree_node.resource.properties('number_of_items').get_value.to_i, true)
    data = YAML.dump(RSS::Parser.parse(content, false).items[range])
    property = tree_node.resource.properties('items')
    property.update_attributes(:text_value => data)
  end
  
  def self.read_and_save_node_media_rss(tree_node, lang)
    
    content = ''
    
    # http://gumnika.kbb1.com/kabbalahmedia/rss_cat.php?CID=3606&DAYS=30&DLANG=ENG
    # http://kabbalahmedia.info/wsxml.php?CID=3629&DLANG=HEB
    # http://www.kabbalahmedia.info/rss.php?UILANG=HEB&DLANG=HEB&CID=246
    
    days_num = (tree_node.resource.properties('days_num')).get_value
    days_num = 3 if !days_num # default is 3 days
    tdate = (Date.today - days_num)
    
    cid = (tree_node.resource.properties('cid')).get_value
    cid = 25 if !cid 
    
    url =  'http://kabbalahmedia.info/wsxml.php?CID=' + cid.to_s + 
           '&DLANG=' + lang +
           '&DF=' + (Date.today).to_s + 
           '&DT=' + tdate.to_s
    
    retries = 2
    begin
      Timeout::timeout(25){
        open(url) { |f|
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

    data = YAML.dump(Hash.from_xml(content))
    property = tree_node.resource.properties('items')
    property.update_attributes(:text_value => data) unless (data.nil? | data.empty?)
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
  
  def get_language(website)
    site_settings = $config_manager.site_settings(website.hrid)
    lang = site_settings[:language] rescue 'english'
    return (lang[0..2]).upcase
  end
  
end 


