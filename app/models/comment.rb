class Comment < ActiveRecord::Base
  
  def self.list_all_comments
		find(:all, :order => "created_at DESC")
	end
	
  def self.list_all_comments_for_page(node_id)
		find(:all, :order => "created_at DESC", :conditions => { :node_id => node_id, :is_spam => false, :is_valid => 1})
	end
  
  
end
