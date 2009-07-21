class Hebmain::Widgets::ShareThis < WidgetManager::Base
  def render_hebrew
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s
    url_prefix = @presenter.website.prefix

    full_url = [url_domain,url_prefix, 'short', url_node].join('/')
    div(:class => 'share_this')
    javascript(:src => "http://s7.addthis.com/js/200/addthis_widget.js")
    javascript{
      rawtext <<-code
    addthis_pub = 'internetkab';
    addthis_language = 'he';
    strurl = "#{full_url}";
    strtitle = "";
    addthis_options = 'facebook, favorites, digg, google,linkedin, live, myspace, stumbleupon, twitter, more';
      code
    }
    a(:href=>"http://www.addthis.com/bookmark.php",
       :onmouseOver => "return addthis_open(this, '', strurl , strtitle )",
       :onmouseOut => "addthis_close()",
       :onclick => "return addthis_sendto()"){
         img :src=>"http://s7.addthis.com/static/btn/sm-plus.gif" , :id => "sharepic", :border=>"0", :alt => _(:share_this)
         text _(:share_this)
       }
  end
  
end