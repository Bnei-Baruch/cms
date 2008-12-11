class Comment < ActiveRecord::Base
  
  belongs_to :tree_node
  
  def self.list_all_comments(page = 1)
    count_comments = count()
    debut = (page*50) - 50
    fin =   50
		content_arrays = find(:all, :order => "created_at DESC", :offset => debut , :limit => fin )
    return {'count_comments' => count_comments, 'content_arrays' => content_arrays}
	end
	
  def self.list_all_comments_for_page(node_id)
		find(:all, :order => "created_at DESC",
      :conditions => { :tree_node_id => node_id, :is_valid => 200})
	end
  
  def self.list_all_non_moderated_comments(page = 1)
    count_comments = count(:all, :conditions => {:is_valid => 0})
    debut = page*50 - 50
    fin =   50
		content_arrays =  find(:all, :order => "created_at DESC",:offset => debut , :limit => fin,
      :conditions => {:is_valid => 0})
    return {'count_comments' => count_comments, 'content_arrays' => content_arrays}
	end
  
  def self.list_all_comments_for_category(cat_id, page = 1)
    count_comments = count(:all, :conditions => {:category => cat_id})
    debut = page*50 - 50
    fin =   50
		content_arrays =  find(:all, :order => "created_at DESC",:offset => debut , :limit => fin,
      :conditions => {:category => cat_id})
    return {'count_comments' => count_comments, 'content_arrays' => content_arrays}
	end
  
  def self.list_non_moderated_comments_for_category(cat_id, page = 1)
    count_comments = count(:all, :conditions => {:category => cat_id, :is_valid => 0})
    debut = (page*50) - 50
    fin =   50
		content_arrays = find(:all, :order => "created_at DESC",:offset => debut , :limit => fin,
      :conditions => {:category => cat_id, :is_valid => 0})
    return {'count_comments' => count_comments, 'content_arrays' => content_arrays}
	end  
end
