module WidgetExtensions
  
  def img_path(image_name)
    "#{domain}/images/#{presenter.site_name}/#{image_name}"
  end                  
  
  def w_class(name)
    presenter.w_class(name) rescue nil
  end
  
  # can pass optional :image_name => 'my_custom_name' to get a specific filtered image
  def get_file_html_url(args_hash)
    attachment = args_hash[:attachment]
    image_name = args_hash.has_key?(:image_name) ? args_hash[:image_name] : 'myself'
    get_file_url(attachment, image_name) if attachment
  end

  def get_page_url(tree_node, options = {})
    args = {:prefix => presenter.controller.website.prefix, :id => tree_node.permalink}
    unless options.empty?
      ags.merge!({:options => options})
    end
    domain + tm_path(args)
  end

  def get_css_url(style_name)
    domain + css_path(:website_id => presenter.controller.website.id, :css_id => style_name)  
  end

  def get_css_external_url(style_name)
    domain + '/stylesheets/' + style_name + '.css'
  end

#  def get_json_url
#    domain + json_path  
#  end

  # this is used to generate URL in development mode
  def port
    @port ||= presenter.port
  end

  def domain
     @full_domain ||= presenter.domain
  end

  def get_file_url(attachment, image_name = 'myself')
    my_domain = domain.sub('http://','')
    format = File.extname(attachment.filename).delete('.')
    image_url(:image_id => ((attachment.id % 100).to_s) , 
              :image_name => attachment.id.to_s + "_" + image_name,
              :format => format, 
              :host => my_domain)
  end
  
  def add_node_link_to_resource(parent_node, resource)
    new_tree_node = 
    TreeNode.new(
      :parent_id => parent_node.id,
      :has_url => false,
      :is_main => false
    )
    new_tree_node.resource = resource
    new_tree_node.save!
  end
  
end