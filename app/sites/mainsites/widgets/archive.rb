class Mainsites::Widgets::Archive < WidgetManager::Base
    
  
  # provide a link using its short expression
  # http://domain.com/prefix/short/$node_id
  
  def render_full
    url_domain = @presenter.domain
    url_permalink = @presenter.node.permalink 
    url_prefix =  @presenter.page_params[:prefix]

    full_url = [url_domain, url_prefix, url_permalink].join('/')
    
    div(:class => 'permalink'){
      img :src => '/images/plus.jpg', :alt => ''
      a(:href => full_url + '?archive'){text _(:'archive')}
    }
  end
end
