class Hebmain::Widgets::ShareThis < WidgetManager::Base
  def render_hebrew
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s
    url_prefix = @presenter.website.prefix

    full_url = [url_domain,url_prefix, 'short', url_node].join('/')
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
    div(:class => 'hadashot'){
        img :src=>"/image/hebmain/hadash.png" , :id => "hadashpic", :border=>"0", :alt => _(:hadashot)
        a(:rel =>"nofollow", :href=>"http://www.hadash-hot.co.il/submit.php?url=#{full_url}&phase=1", :target=>"_blank"){
        text _(:hadashot)
      }
    }
    div(:class => 'shavekria'){
        img :src=>"/image/hebmain/shaveh.png" , :id => "shavekriapic", :border=>"0", :alt => _(:shavekria)
        a(:rel =>"nofollow", :href=>"http://shaveh.co.il/submit.php?url=#{full_url}", :target=>"_blank"){
        text _(:shavekria)
      }
    }
  end
  
end