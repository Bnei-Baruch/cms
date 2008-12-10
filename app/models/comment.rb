class Comment < ActiveRecord::Base
  
 belongs_to :tree_node
  
  def self.list_all_comments
		find(:all, :order => "created_at DESC")
	end
	
  def self.list_all_comments_for_page(node_id)
		find(:all, :order => "created_at DESC",
            :conditions => { :node_id => node_id, :is_valid => 200})
	end
  
  def self.list_all_non_moderated_comments
		find(:all, :order => "created_at DESC",
            :conditions => {:is_valid => 0})
	end
  
  def self.list_all_comments_for_category(cat_id)
		find(:all, :order => "created_at DESC",
            :conditions => {:category => cat_id})
	end
  
  def self.list_non_moderated_comments_for_category(cat_id)
		find(:all, :order => "created_at DESC",
            :conditions => {:category => cat_id, :is_valid => 0})
	end  
end
