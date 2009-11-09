class Comment < ActiveRecord::Base
  
  belongs_to :tree_node
  
  NBCOMMENTPERPAGE = 50
  
  def self.list_all_comments(page = 1)
    list_comments(page)
	end
	
  def self.list_all_comments_for_page(node_id, limit = nil, offset = nil)
    args = {:order => "created_at DESC", :conditions => { :tree_node_id => node_id, :is_valid => 200}}
    args.merge!({:limit  => limit}) if limit
    args.merge!({:offset  => offset}) if (limit && offset)
		find(:all, args)
	end
	
	def self.get_comment(comment_id)
	  Comment.find(:first, :conditions => [ "id = ? AND is_valid = ?", comment_id, 200])
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
	
  # Returns the main section of a specified tree_node
	def self.get_category(tree_node)
	  Thread.current[:presenter].main_sections & tree_node.ancestors
	end
	
	def self.create_comment(tree_node, args)
	  category = get_category(tree_node).first
	  new_comment = Comment.new(:title => args[:title],
                              :name => args[:name],
                              :email => args[:email],
                              :body => args[:body],
                              :tree_node_id => tree_node.id,
                              :is_spam => false,
                              :is_valid => args[:is_valid],
                              :category => category.id)
    new_comment.save
	end  
  
  private
#   Used for administration
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
