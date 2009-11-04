class Sites::ApiController < ApplicationController

  def documentation
    respond_to do |format| 
      format.html
    end 
  end

  # GET http://mydomain.com/api/categories.format
  def get_categories
     @categories = @presenter.main_sections(2)
     respond_to do |format| 
       format.xml 
       format.html { render :text  => 'html contentis not supported. Please try the same url with .xml extension' } 
     end 
  end
  
  # GET http://mydomain.com/api/categories/:category_id.format
  def get_category
    
  end

  # GET http://mydomain.com/api/categories/:category_id/articles.format
  def get_category_articles
    category_id = params[:category_id]
    unless category_id
      render :text  => 'Missing parameter: \'category_id\' is required' unless category_id
      return
    end

    per_page = params[:per_page]
    page_num = params[:page_num]
    @articles = articles(category_id, per_page, page_num)
    respond_to do |format| 
      format.xml 
      format.html { render :text  => 'html contentis not supported. Please try the same url with .xml extension' } 
    end 
  end

  # GET http://mydomain.com/api/articles/:article_id.format
  def get_article
    article_id = params[:article_id]
    @tree_node = TreeNode.find(article_id)
    respond_to do |format| 
      format.xml 
      format.html { render :text  => 'html contentis not supported. Please try the same url with .xml extension' } 
    end 
  end
  
  private
  # :current_page => 3 - integer - optional - default: paging is disabled
  # :items_per_page => 10 - integer - optional - default: 25 items per page(if current page key presents)
  
  def articles(parent_id, per_page = nil, page_num = nil)
    return nil unless parent_id
    args = {:parent => parent_id, 
    :resource_type_hrids => ['content_page'], 
    :depth => 1,
    :has_url => true,
    :properties => 'b_acts_as_section = false'
    }
    args
    if page_num
      args.merge!({:current_page => page_num})
      if per_page
        args.merge!({:items_per_page => per_page})
      end
    end
    TreeNode.get_subtree(args)
  end
  
end