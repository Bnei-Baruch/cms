class Mainsites::Widgets::ShareThis < WidgetManager::Base
  def render_hebrew
    url_domain = @presenter.domain
    url_node = @presenter.node.id.to_s
    url_prefix = @presenter.website.prefix
    permalink = @presenter.permalink

    full_url = [url_domain, url_prefix, 'short', url_node].join('/')
    like_url = [url_domain, url_prefix, permalink].join('/')
    div(:class => 'share_this'){
			div(:class => 'like_it'){
				rawtext <<-LIKE_BUTTON
					<iframe src="http://www.facebook.com/plugins/like.php?locale=he_IL&amp;href=#{like_url}&amp;layout=button_count&amp;show_faces=false&amp;width=90&amp;action=like&amp;font&amp;colorscheme=light&amp;height=21" scrolling="no" frameborder="0" style="overflow:hidden;width:90px;height:20px;float:right;" allowTransparency="true"></iframe>
				LIKE_BUTTON
			}
      javascript(:src => "http://s7.addthis.com/js/200/addthis_widget.js")
      javascript{
        rawtext <<-code
    addthis_pub = 'internetkab';
    addthis_language = 'he';
    strurl = "#{full_url}";
    strtitle = "";
    addthis_options = 'facebook, favorites, digg, google,linkedin, live, myspace, stumbleupon, twitter, more';
    addthis_config = {data_ga_property: 'UA-548326-62'};
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
