class Hebmain::Widgets::Shortcut < WidgetManager::Base
    
  
  # provide a link using its short expression
  # http://domain.com/prefix/short/$node_id
  
  def render_full
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s 
    url_prefix =  params[:prefix]

    full_url = [url_domain,url_prefix, 'short', url_node].join('/')
    
    div(:class => 'permalink'){
      img :src => '/images/plus.jpg', :alt => ''
      a(:href => full_url){text 'לינק ישיר לכתבה'}
    }
  end
end
