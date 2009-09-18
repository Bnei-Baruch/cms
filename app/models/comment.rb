class Comment < ActiveRecord::Base
  
  belongs_to :tree_node
  
  NBCOMMENTPERPAGE = 50
  
  def self.list_all_comments(page = 1, root = nil)
    list_comments(page, '0', false, root)
	end
	
  def self.list_all_comments_for_page(node_id)
		find(:all, :order => "created_at DESC",
      :conditions => { :tree_node_id => node_id, :is_valid => 200})
	end
  
  def self.list_all_non_moderated_comments(page = 1, root = nil)
    list_comments(page, '0', true, root)
	end
  
  def self.list_all_comments_for_category(cat_id, page = 1, root = nil)
    list_comments(page, cat_id, false, root)
	end
  
  def self.list_non_moderated_comments_for_category(cat_id, page = 1, root = nil)
    list_comments(page, cat_id, true, root)
	end  
  
  private
  
  def self.list_comments(page, category = '0', only_non_moderated = false, root = nil)
    comment_per_page = NBCOMMENTPERPAGE
    start_from = page * (comment_per_page - 1)
    conditions = {}
    conditions[:is_valid] = 0 if only_non_moderated
    conditions[:category] = category unless category == '0'

    number_of_comments = count(:all, :conditions => conditions)
    if number_of_comments > 0
      # Only from THIS site
      if root
        comments = find(:all, :order => "created_at DESC",:offset => start_from,
          :conditions => conditions)
        children = ([root] + root.descendants).map { |c| c.id }
        comments = comments.select { |comment|
          children.include?(comment.tree_node_id)
        }
        number_of_comments = comments.size
      else
        comments = find(:all, :order => "created_at DESC",:offset => start_from,
          :limit => comment_per_page,
          :conditions => conditions)
      end
    else
      comments = []
    end
    {'count_comments' =>  number_of_comments, 'content_arrays' => comments}
  end

end
