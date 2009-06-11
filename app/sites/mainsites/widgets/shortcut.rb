class Mainsites::Widgets::Shortcut < WidgetManager::Base
    
  
  # provide a link using its short expression
  # http://domain.com/prefix/short/$node_id
  
  def render_full
    uri = URI.parse(@presenter.domain)
    url_node = @presenter.node.id.to_s 
    url_prefix = @presenter.website.prefix

    full_url = short_url(:host => uri.host, :port => uri.port, :prefix => url_prefix, :id => url_node)
    
    javascript {
      rawtext <<-Embedjs
        $(document).ready(function() {
           $("#directLinkForm #direct_link").focus(function(){
                  val = $(this).attr("value");
                  $(this).attr({value: ''});
                  $(this).attr({value: val});
            })
        })
      Embedjs
    } 
    div(:class => 'permalink',
      :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/services.gif)"){
      form(:action => '', :id => 'directLinkForm'){
        p{
          text _(:direct_link)
          input(:type => 'text', :readonly => 'readonly', :value => full_url, :id => 'direct_link'
          )
        }
      }
    }
  end
end
