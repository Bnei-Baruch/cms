class AddDataSystemGroups < ActiveRecord::Migration
  def self.up
    Group.destroy_all
    admin_group = Group.create(:groupname => 'Administrators', :is_system_group => true )
    Group.create(:groupname => 'User manager', :is_system_group => true )
    Group.create(:groupname => 'Nodes Access Rights', :is_system_group => true )
    
    User.destroy_all
   # User.create(:username => 'Admin', :user_password =>'kavana')
    #AdminGroup = Group.find_by_groupname('Administrators')(0)
    admin_group.users.create(:username => 'Admin', :user_password =>'kavana')
   # AdminUser = User.find_by_username('Admin')
  end

  def self.down
    Group.destroy_all
    User.destroy_all
  end
end
