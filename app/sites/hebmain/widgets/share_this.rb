class Hebmain::Widgets::ShareThis < WidgetManager::Base
  def render_hebrew
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s
    url_prefix = @presenter.website.prefix
    permalink = @presenter.permalink

    full_url = [url_domain, url_prefix, 'short', url_node].join('/')
    like_url = [url_domain, url_prefix, permalink].join('/')
    div(:class => 'like_it'){
      rawtext <<-LIKE_BUTTON
        <iframe src="http://www.facebook.com/plugins/like.php?href=#{like_url}&amp;layout=button_count&amp;show_faces=false&amp;width=450&amp;action=like&amp;font&amp;colorscheme=light&amp;height=35" scrolling="no" frameborder="0" style="border:1px solid white; overflow:hidden; width:450px; height:35px;" allowTransparency="true"></iframe>
      LIKE_BUTTON
    }
    div(:class => 'share_this'){
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
    }
  end
  
end