class Comment < ActiveRecord::Base
  
  belongs_to :tree_node
  
  NBCOMMENTPERPAGE = 50
  
  def self.list_all_comments(page = 1)
    list_comments(page)
	end
	
  def self.list_all_comments_for_page(node_id)
		find(:all, :order => "created_at DESC",
      :conditions => { :tree_node_id => node_id, :is_valid => 200})
	end
  
  def self.list_all_non_moderated_comments(page = 1)
    list_comments(page, "0", true)
	end
  
  def self.list_all_comments_for_category(cat_id, page = 1)
    list_comments(page, cat_id)
	end
  
  def self.list_non_moderated_comments_for_category(cat_id, page = 1)
    list_comments(page, cat_id, true)
	end  
  
  private
  
  def self.list_comments(page, category = "0", only_non_moderated = false)
    comment_per_page = NBCOMMENTPERPAGE
    start_from = (page*comment_per_page)-comment_per_page
    conditions = {}
    if only_non_moderated
      conditions.store(:is_valid, 0)
    end 
    unless category == "0" 
      conditions.store(:category, category)
    end
    number_of_comments = count(:all, :conditions => conditions)
    comments = find(:all, :order => "created_at DESC",:offset => start_from,
      :limit => comment_per_page,
      :conditions => conditions)
    {'count_comments' =>  number_of_comments, 'content_arrays' => comments}
  end
  
  
end
