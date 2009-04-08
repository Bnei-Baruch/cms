class Mainsites::Widgets::Shortcut < WidgetManager::Base
    
  
  # provide a link using its short expression
  # http://domain.com/prefix/short/$node_id
  
  def render_full
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s 
    url_prefix = @presenter.website.prefix

    full_url = [url_domain,url_prefix, 'short', url_node].join('/')
    
    div(:class => 'permalink',
      :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/services.gif)"){
      form(:action => '', :name => 'directLinkForm'){
        p{
          text _(:direct_link)
          input(:type => 'text', :readonly => 'readonly', :value => full_url, :name => 'direct_link',
            :onclick => 'javascript:document.directLinkForm.direct_link.focus();document.directLinkForm.direct_link.select();'
          )
        }
      }
    }
  end
end
