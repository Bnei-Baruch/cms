# This module is used by Cron 
# Usage: ruby script/runner 'CronManager.read_and_save_rss' -e development
#        ruby script/runner 'CronManager.read_and_save_media_rss' -e development
#        ruby script/runner 'CronManager.sweep_cache' -e development

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'timeout'
require 'cgi'
require 'benchmark'

class CronManager

# This methos is responsible to update all rss resources 
# which aggregate content from external rss feeds.
  def self.read_and_save_rss
   
    AuthenticationModel.cron_manager_user_login
    websites = Website.find(:all, :conditions => ["entry_point_id<>?", 0])
    
    websites.each do |website|
      website_tree_node = TreeNode.find(:first, :conditions => ["resource_id = ?", website.entry_point_id])

      if (website_tree_node)
        # Workaround:
        # TreeNode.get_subtree doesn't work properly recursively
        # so let's add content_pages and then filter them out
        tree_nodes = TreeNode.get_subtree(
          :parent => website_tree_node.id,
          :resource_type_hrids => ['rss', 'content_page']
        ).select{|node|
          node.resource.resource_type.hrid=='rss'}

        tree_nodes.each do |tree_node|
          begin
            read_and_save_node_rss(tree_node)
          rescue
            puts 'FAILURE!!!'
          end
        end
      end
    end
  end

# This method is responsible to update all media_rss resources 
# which aggregate content from our kabbalahmedia website according to category ID
  def self.read_and_save_media_rss
   
    AuthenticationModel.cron_manager_user_login
    websites = Website.find(:all, :conditions => ["entry_point_id<>?", 0])
    
    websites.each do |website|
      website_tree_node = TreeNode.find(:first, :conditions => ["resource_id = ?", website.entry_point_id])

      if (website_tree_node)
        tree_nodes = TreeNode.get_subtree(
          :parent => website_tree_node.id,
          :resource_type_hrids => ['media_rss']
        )

        tree_nodes.each do |tree_node|
          read_and_save_node_media_rss(tree_node, get_language(website))
        end
      end
    end
  end
  
  def self.read_and_save_node_rss(tree_node)
    content = ''
    
    url = (tree_node.resource.properties('url')).get_value
    url_encoded = CGI.escape(url)
    url_encoded.gsub!('%3A', ':')
    url_encoded.gsub!('%2F', '/')
    url_encoded.gsub!('%3F', '?')
    url_encoded.gsub!('%26', '&')
    url_encoded.gsub!('%3D', '=')
    print "Read Tree Node #{tree_node.id} #{url_encoded} "

    retries = 2
    begin
      Timeout::timeout(25){
        begin
          open(url_encoded) { |f|
            content = f.read
          }
        rescue
          puts 'Failed to open url ' + url_encoded
          return
        end
      }
    
    rescue Timeout::Error
      retries -= 1
      if retries > 0
        sleep 0.42 and retries
      else
        raise
      end
    end
    #    puts "RSS #{content}"
    range = Range.new(0, tree_node.resource.properties('number_of_items').get_value.to_i, true)
    begin
      data = YAML.dump(RSS::Parser.parse(content, false).items[range])
    rescue
      puts 'Failed to parse rss from ' + url
      return
    end
    property = tree_node.resource.properties('items')
    unless property.text_value == data
      property.update_attributes(:text_value => data)
      tree_node.resource.save
    else
      print "No changes\n"
    end
    puts 'OK'
    data
  end
  
  def self.read_and_save_node_media_rss(tree_node, lang)
    
    content = ''
    
    #days_num = (tree_node.resource.properties('days_num')).get_value
    #days_num = 3 if !days_num # default is 3 days
    days_num = 30
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
        begin
          open(url) { |f|
            content = f.read
          }
        rescue
          puts 'Failed to open url ' + url
          return
        end
        
      }
    
    rescue Timeout::Error
      retries -= 1
      if retries > 0
        sleep 0.42 and retries
      else
        raise
      end
    end

    begin
      lessons = Hash.from_xml(content)
    rescue
      puts 'Failed to parse xml from ' + url
      return
    end
    lessons['lessons']['lesson'].each do |lesson|
      begin
        lesson['date'] = (Time.parse(lesson['date'])).strftime('%d.%m.%Y')
      rescue Exception  => e
        RAILS_DEFAULT_LOGGER.error("error in cron_manager.rb(#{Time.now}):")
        RAILS_DEFAULT_LOGGER.error(e)
      end

    end
    
    data = YAML.dump(lessons)
    property = tree_node.resource.properties('items')
    unless property.text_value == data
      property.update_attributes(:text_value => data) unless (data.nil? | data.empty?)
      tree_node.resource.save
    end
    data
  end
  
  private
  
  
  def self.get_language(website)
    site_settings = $config_manager.site_settings(website.hrid)
    lang = site_settings[:language] rescue 'english'
    return (lang[0..2]).upcase
  end
  
end 


