class MoveLeftLessons2LessonPlaceholder < ActiveRecord::Migration
  def self.up
    msession = Hash.new
    username = $config_manager.appl_settings[:cron_manager_login_user][:username]
    password = $config_manager.appl_settings[:cron_manager_login_user][:password]
    user = User.authenticate(username, password)
    if user
      msession[:user_id] = user.id
      msession[:current_user_is_admin] = user.groups.find(:all, :conditions => {:groupname=>'Administrators'}).length
    else
      raise "Access denied for Rss Reader user."
    end
    Thread.current[:session] = msession
    
    resource_type = ResourceType.find(:first, :conditions => ['hrid = ?', 'media_rss'])
    resource_type_ids = Resource.find(:all, :conditions => ['resource_type_id = ?', resource_type])
    tree_nodes = TreeNode.old_find(:all, :conditions => ["placeholder='left' and resource_id in (?)", resource_type_ids])
    tree_nodes.each {|t|
      t.placeholder = 'lesson'
      t.save!
    }
  end

  def self.down
  end
end
