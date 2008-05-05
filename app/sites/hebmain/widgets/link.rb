class Hebmain::Widgets::Link < Widget::Base
  
  attr_reader :resource, :view_mode
  
  def initialize(args_hash = {})
    super
    unless args_hash.is_a?(Hash)
      raise 'the parameter is not a hash'
    end
    @resource = args_hash[:tree_node].resource rescue nil
    @view_mode = args_hash[:view_mode] || 'full'
    # self.class_eval do
    #   alias_method :render, "#{view_mode}_mode".to_sym
    # end
  end
  
  def render
    self.send(view_mode + '_mode')
  end
  
  def full_mode
    a get_name, :href => get_url, :alt => get_alt if resource
  end
  
  
  private

  def get_name
    resource.name rescue ''
  end
  
  def get_url
    resource.properties('url').value rescue ''
  end
  
  def get_alt
    resource.properties('alt').value rescue ''
  end
end
