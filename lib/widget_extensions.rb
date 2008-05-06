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

  def get_page_url(tree_node)
    domain + tm_path(:prefix => presenter.controller.website.prefix, :id => tree_node.permalink)
  end

  def get_css_url(style_name)
    domain + css_path(:website_id => presenter.controller.website.id, :css_id => style_name)  
  end

  def get_css_external_url(style_name)
    domain + '/stylesheets/' + style_name + '.css'
  end

  # this is used to generate URL in development mode
  def port
        my_port = presenter.controller.request.server_port.to_s
        my_port == '80' ? '' : ':' + my_port
  end

  def domain
     @full_domain ||= presenter.controller.website.domain + port
  end

  def get_file_url(attachment, image_name = 'myself')
    my_domain = domain.sub('http://','')
    format = File.extname(attachment.filename).delete('.')
    image_url(:image_id => attachment.id, :image_name => image_name,:format => format, :host => my_domain)
  end
  
end