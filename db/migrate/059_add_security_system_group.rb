class AddSecuritySystemGroup < ActiveRecord::Migration
  def self.up
    #create "system manager" group for lookup administration
    Group.find_or_create_by_groupname(:groupname => "System manager", :is_system_group => true )
   
    #create "public group" for anonymous users 
    public_group = Group.find_or_create_by_groupname(:groupname => "Public group", :is_system_group => false )
    #create "anonymous" user for anonymous access
    public_group.users.find_or_create_by_username(:username => "Anonymous", :user_password =>"bli_kavana")
   
  end

  def self.down
     system_group = Group.find(:first, :conditions => {:groupname => "System manager"})
     system_group.destroy if system_group
   
     public_group = Group.find(:first, :conditions => {:groupname => "Public group"})
     public_group.destroy if public_group
     
     anonymous_user = User.find(:first, :conditions => {:username => "Anonymous"})
     anonymous_user.destroy if anonymous_user
  end
end
