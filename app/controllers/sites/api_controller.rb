class Sites::ApiController < ApplicationController
  include TemplateExtensions

  def documentation
    respond_to do |format|
      format.html
    end
  end

  def get_all_article_ids
    @articles = []
    categories(3).each do |cat|
      articles(cat.id).each do |article|
        @articles << get_article_data(article)
      end
    end
  end

  require 'ekuseru'
  def get_all_articles
    @articles = []
    categories(3).each do |cat|
      articles(cat.id).each do |article|
        begin
          @articles << get_article_data(article)
        rescue
          puts "@@@@@"
        end
      end
    end
    respond_to do |format|
      format.xml
      format.xls
      format.csv { render :text => to_csv(@articles) }
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end


  # GET http://mydomain.com/api/categories.format
  def get_categories
    @categories = categories(3)
    respond_to do |format|
      format.xml
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end

  # GET http://mydomain.com/api/articles.format
  def get_category_articles
    category_id = params[:category_id]
    unless category_id
      render :text => '<error>Missing parameter: \'category_id\' is required</error>'
      return
    end

    per_page = params[:per_page]
    page_num = params[:page_num]
    @articles = articles(category_id, per_page, page_num)
    respond_to do |format|
      format.xml
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end

  def get_file_url(attachment, image_name = 'myself')
    domain = @presenter.domain
    my_domain = domain.sub('http://', '')
    format = File.extname(attachment.filename).delete('.')
    image_url(:image_id => ((attachment.id % 100).to_s),
              :image_name => attachment.id.to_s + "_" + image_name,
              :format => format,
              :host => my_domain)
  end

  # GET http://mydomain.com/api/article.format
  def get_article
    @article = get_article_data(params[:article_id])

    respond_to do |format|
      format.xml
      format.json {
        render :json => @article, :callback => params[:callback]
      }
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end

  # GET http://mydomain.com/api/article_comments.format
  def get_article_comments
    article_id = params[:article_id]
    unless article_id.is_integer?
      render :text => "Invalid input syntax #{article_id}: \'article_id\' must be integer"
      return
    end
    limit = (params[:per_page] || 1000).to_i
    page_num = (params[:page_num] || 1).to_i
    page_num -= 1
    offset = limit * page_num

    @total_comments = Comment.count_comments(article_id)
    @comments = Comment.list_all_comments_for_page(article_id, limit, offset)

    respond_to do |format|
      format.xml
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end

  # GET http://mydomain.com/api/article_comment.format
  def get_article_comment
    comment_id = params[:comment_id]
    @comment = Comment.get_comment(comment_id)
  end

  # POST http://mydomain.com/api/article_comment.format
  def add_comment_to_article
    article_id = params[:article_id]
    args = Hash.new
    args[:title] = params[:title]
    args[:name] = params[:name]
    args[:email] = params[:email]
    args[:body] = params[:body]
    args[:is_valid] = 0
    args[:is_valid] = 200 if params[:is_valid] == '1'

    error_message = Hash.new
    error_message[:article_id] = "Missing parameter: \'article_id\' is required" if article_id.empty?
    error_message[:title] = "Missing parameter: \'title\' is required" if args[:title].empty?
    unless error_message.empty?
      render :xml => {:respond => error_message}
      return
    end

    begin
      tree_node = TreeNode.find(article_id)
    rescue Exception => e
      render :xml => {:respond => "Article not found: article ID:#{article_id}"}
      return
    end

    respond_to do |format|
      if Comment.create_comment(tree_node, args)
        format.html { render :text => "Comment for article ID:#{article_id} created successfully" }
        format.xml { render :xml => {:respond => "Comment for article ID:#{article_id} created successfully"} }
      else
        format.html { render :text => "Creation of comment for article ID:#{article_id} has failed" }
        format.xml { render :xml => {:respond => "Creation of comment for article ID:#{article_id} has failed"} }
      end
    end

  end

  # GET http://mydomain.com/api/first_page_article.format
  def get_first_page_article
    @tree_node = first_article.first
    @tree_node = random_article unless @tree_node && @tree_node.resource
    unless @tree_node
      render :text => 'No one node is marked as a mobile one'
      return
    end
    respond_to do |format|
      format.xml
      format.html { render :text => 'html content is not supported. Please try the same url with .xml extension' }
    end
  end

  private
  # :current_page => 3 - integer - optional - default: paging is disabled
  # :items_per_page => 10 - integer - optional - default: 25 items per page(if current page key presents)

  def random_article
    args = {:parent => @presenter.website_node.id,
            :resource_type_hrids => ['content_page'],
            :depth => 10,
            :has_url => true,
            :properties => 'b_acts_as_section = false AND b_mobile_content = true',
            :sort_field => 'updated_at',
            :sort_order => 'DESC',
    }
    nodes = TreeNode.get_subtree(args)
    return nil unless nodes
    nodes[rand(nodes.size)]
  end

  def articles(parent_id, per_page = nil, page_num = nil)
    return nil unless parent_id
    properties = show_only_mobile_content? ? 'b_acts_as_section = false AND b_mobile_content = true' : 'b_acts_as_section = false'
    args = {:parent => parent_id,
            :resource_type_hrids => ['content_page'],
            :depth => 1,
            :has_url => true,
            :properties => properties,
            :sort_field => 'updated_at',
            :sort_order => 'DESC'
    }
    if page_num
      args.merge!({:current_page => page_num})
      if per_page
        args.merge!({:items_per_page => per_page})
      end
    end
    TreeNode.get_subtree(args)
  end

  def categories(depth = 1)
    properties = show_only_mobile_content? ? 'b_acts_as_section = true AND b_mobile_content = true' : 'b_acts_as_section = true'
    TreeNode.get_subtree(
        :parent => @presenter.website_node.id,
        :resource_type_hrids => ['content_page'],
        :depth => depth,
        :has_url => true,
        :properties => properties
    )
  end

  def first_article
    TreeNode.get_subtree(
        :parent => @presenter.website_node.id,
        :resource_type_hrids => ['content_page'],
        :has_url => true,
        :depth => 4,
        :properties => 'b_acts_as_section = false AND b_mobile_first_page = true'
    )
  end

  def show_only_mobile_content?
    params[:filter_by] && params[:filter_by] == 'mobile'
  end

  def get_article_data(article_id)
    tree_node = article_id.kind_of?(TreeNode) ? article_id : TreeNode.find(article_id)
    children = TreeNode.get_subtree(
        :parent => tree_node.id,
        :resource_type_hrids => ['article', 'content_preview', 'section_preview', 'rss', 'video', 'media_rss', 'video_gallery', 'media_casting', 'campus_form', 'iframe', 'title', 'manpower_form', 'picture_gallery', 'audio_gallery', 'newsletter', 'popup'],
        :depth => 1,
        :has_url => false,
        :placeholders => ['main_content'],
        :status => ['PUBLISHED']
    ).map { |tn|
      class_name = tn.resource.resource_type.hrid
      render_to_string(:widget => w_class(class_name), :tree_node => tn,
                       :view_mode => 'full', :options => {}, :layout => false)
    }.join

    resource = tree_node.resource
    rp = resource.properties('preview_image')
    image_object = Attachment.get_short_attachment(rp.id) rescue nil
    body = resource.get_resource_property_by_property_hrid('body')
    comments = tree_node.comments

    {
        :category_id => tree_node.parent_id,
        :article_id => tree_node.id,
        :slug => tree_node.permalink,
        :updated_at => resource.updated_at,
        :author => (resource.get_resource_property_by_property_hrid('writer') rescue ''),
        :title => resource.name,
        :description => (resource.get_resource_property_by_property_hrid('description') rescue ''),
        :body => CGI.unescapeHTML(body + children),
        :num_of_comments => comments ? comments.size : 0,
        :image => image_object && get_file_url(image_object, 'medium')
    }

  end

  def to_csv(articles)
    require 'csv'

    column_names = [:article_id, :updated_at, :body, :title, :description, :slug, :image]
    column_header = [:post_id, :post_date, :post_content, :post_title, :post_excerpt, :post_name, :post_thumbnail]
    articles.map{|a| a.values_at(*column_names)}.unshift(column_header).inject('') do |buf, article|
      CSV.generate_row(article, 8, buf)
      buf
    end
  end
end
