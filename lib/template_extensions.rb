module TemplateExtensions
  def self.included(cls)
    cls.extend ClassMethods
  end
  
  module ClassMethods
    
  end
  
  def w_class(resource)
    my_widget_path(resource).camelize.constantize 
  end
  
  def t_class(resource)
    my_template_path(resource).camelize.constantize
  end

  def l_class(resource)
    l_class_str = site_settings[:layout_map][resource]
    l_class_str = resource if l_class_str.nil?
    my_layout_path(l_class_str).camelize.constantize
  end
  
  
  private     

  def my_layout_path(resource)
    get_my_path('layouts', site_name, group_name, resource, 'rb')
  end

  def my_template_path(resource)
    get_my_path('templates', site_name, group_name, resource, 'rb')
  end

  def my_stylesheets_path(style_name)
    get_my_path('stylesheets', site_name, group_name, style_name, 'css.erb')
  end

  def my_widget_path(resource)
    get_my_path('widgets', site_name, group_name, resource, 'rb')
  end
  
  def get_my_path(type, sitename, groupname, filename, extention)
    result = search_path(type, sitename, groupname, filename, extention)
      
    return result if result
    
    if File.exists?("#{RAILS_ROOT}/app/sites/#{sitename}/#{type}/#{filename}.#{extention}")
      insert_path(type, sitename, filename, extention)
      "#{sitename}/#{type}/#{filename}"
    elsif File.exists?("#{RAILS_ROOT}/app/sites/#{groupname}/#{type}/#{filename}.#{extention}")
      insert_path(type, groupname, filename, extention)
      "#{groupname}/#{type}/#{filename}"
    else 
      insert_path(type, 'global', filename, extention)
      "global/#{type}/#{filename}"
    end
  end
  
  def insert_path(type, name, filename, extention)
    $files_location << {:type => type, :name => name, :filename => filename, :extention => extention}
  end
  
  def search_path(type, sitename, groupname, filename, extention)
    result = [sitename, groupname, 'global'].detect do |name|
      $files_location.include?({:type => type, :name => name, :filename => filename, :extention => extention})
    end
    return nil unless result
    "#{result}/#{type}/#{filename}"
  end
  
end