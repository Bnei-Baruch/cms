class Hebmain::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_breadcrumbs = ext_breadcrumbs
    layout.ext_content_header = ext_content_header
    layout.ext_title = ext_title
    layout.ext_description = ext_description
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
    layout.ext_kabtv_exist = ext_kabtv_exist
    layout.ext_abc_up =  ext_abc_up
    layout.ext_abc_down = ext_abc_down
    layout.ext_keywords = ext_keywords
  end


  def ext_abc_up
    WidgetManager::Base.new do
      role = get_abc_role
      if role == "a"
        rawtext <<-JSA
          <script>
          //a up
          function utmx_section(){}function utmx(){}
          (function(){var k='#{get_abc_check_code}',d=document,l=d.location,c=d.cookie;function f(n){
          if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return c.substring(i+n.
          length+1,j<0?c.length:j)}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
          d.write('<sc'+'ript src="'+
          'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
          +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
          +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
          '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
          </script><script>utmx("url",'A/B');</script>
        JSA
      end
    end
  end

  def ext_abc_down
    WidgetManager::Base.new do
      role = get_abc_role
      case role
      when "a"
        rawtext <<-JSA
          <script type="text/javascript">
          //a down
          if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
          (document.location.protocol=='https:'?'s://ssl':'://www')+
          '.google-analytics.com/ga.js"></sc'+'ript>')</script>
          <script type="text/javascript">
          try {
          var pageTracker=_gat._getTracker("#{get_abc_ua_tracker}");
          pageTracker._trackPageview("/#{get_abc_check_code}/test");
          }catch(err){}</script>
        JSA
      when "b"
        rawtext <<-JSB
          <script type="text/javascript">
          //b down
          if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
          (document.location.protocol=='https:'?'s://ssl':'://www')+
          '.google-analytics.com/ga.js"></sc'+'ript>')</script>
          <script type="text/javascript">
          try {
          var pageTracker=_gat._getTracker("#{get_abc_ua_tracker}");
          pageTracker._trackPageview("/#{get_abc_check_code}/test");
          }catch(err){}</script>
        JSB
      when "c"
        rawtext <<-JSC
          <script type="text/javascript"><!--
          //c down
          if(typeof(_gat)!='object')document.write('<sc'+'ript src="http'+
          (document.location.protocol=='https:'?'s://ssl':'://www')+
          '.google-analytics.com/ga.js"></sc'+'ript>')
          // --></script>
          <script type="text/javascript"><!--
          try {
          var pageTracker=_gat._getTracker("#{get_abc_ua_tracker}");
          pageTracker._trackPageview("/#{get_abc_check_code}/goal");
          }catch(err){}
          // --></script>
        JSC
      end
    end
  end

  def ext_kabtv_exist
    !content_header_resources.blank?
  end
  
  def ext_breadcrumbs
    WidgetManager::Base.new(helpers) do
      hide_breadcrumbs = get_hide_breadcrumbs
      if (hide_breadcrumbs.is_a?(String) && hide_breadcrumbs.empty?) || (not hide_breadcrumbs)
        div(:class => 'middle'){
          div(:class => 'h1') {
            w_class('breadcrumbs').new(:view_mode => 'titles').render_to(self)
            div(:class =>'h1-right')
            div(:class =>'h1-left')
          }
          w_class('breadcrumbs').new().render_to(self) 
          div(:class => 'margin-25') {text ' '}
        }
      end     
    end
  end
  def ext_content_header
    WidgetManager::Base.new(helpers) do
      if @presenter.page_params.has_key?('archive') || !get_acts_as_section
        w_class('cms_actions').new(:tree_node => @tree_node,
          :options => {:buttons => %W{ new_button },
            :resource_types => %W{ kabtv errormsg map article },
            :button_text => _(:admin_upper_part),
            :new_text => _(:create_new_wide_unit),
            :has_url => false, :placeholder => 'main_content_header'}).render_to(self)
        if AuthenticationModel.current_user_is_admin?
          w_class('cms_actions').new(:tree_node => @tree_node,
            :options => {:buttons => %W{ new_button },
              :resource_types => %W{ admin_comment },
              :button_text => _(:admin_management),
              :new_text => _(:create_module_admin_comment),
              :has_url => false, :placeholder => 'main_content_header'}).render_to(self)
        end
      elsif get_acts_as_section
        w_class('cms_actions').new(:tree_node => @tree_node,
          :options => {:buttons => %W{ new_button },
            :resource_types => %W{ article },
            :button_text => _(:admin_upper_part),
            :new_text => _(:create_new_wide_unit),
            :has_url => false, :placeholder => 'main_content_header'}).render_to(self)
      end
      
      content_header_resources.each{|e|
        div(:id => sort_id(e), :class => "item#{' draft' if e.resource.status == 'DRAFT'}") {
          sort_handle
          render_content_resource(e)
          div(:class => 'clear')
        }
      }
      content_header_resources
    end
  end

  def ext_content
    WidgetManager::Base.new(helpers) do
      if !@presenter.page_params.has_key?('archive') || !get_acts_as_section
        w_class('cms_actions').new(:tree_node => @tree_node,
          :options => {:buttons => %W{ new_button edit_button },
            :resource_types => %W{ article content_preview section_preview rss video media_rss video_gallery media_casting campus_form iframe title manpower_form picture_gallery audio_gallery newsletter},
            :button_text => 'ניהול דף תוכן',
            :new_text => 'צור יחידת תוכן חדשה',
            :edit_text => 'ערוך דף תוכן',
            :has_url => false, :placeholder => 'main_content'}).render_to(self)
      end
      
      hide_title = get_hide_title
      if (hide_title.is_a?(String) && hide_title.empty?) || (not hide_title)
        h1 get_title
        small_title = get_small_title
        h2 get_small_title unless small_title.empty?
        sub_title = get_sub_title
        div(:class => 'descr') { text get_sub_title } unless sub_title.empty?
        my_date = get_date
        writer = get_writer
        unless my_date.empty? && writer.empty?
          div(:class => 'author') {
            span'תאריך: ' + my_date, :class => 'left' unless my_date.empty?
            unless writer.empty?
              span(:class => 'right') {
                text 'מאת: '
                unless get_writer_email.empty?
                  a(:href => 'mailto:' + get_writer_email){
                    img(:src => img_path('email.gif'), :alt => 'email')
                    text ' ' + writer
                  }
                else
                  text ' ' + writer
                end
              }
            end
          }
        end
      end
      unless get_body.empty?
        div(:class => "item#{' draft' if @tree_node.resource.status == 'DRAFT'}") {
          rawtext get_body
        }
      end
      
      if @presenter.page_params.has_key?('archive') && get_acts_as_section
        div(:class => 'index sortable') {
          content_resources.each_with_index { |item, index|  
            klass = index.odd? ? 'element preview-even' : 'element preview-odd'
            div(:class => klass, :id => sort_id(item)) {
              sort_handle
              render_content_item(item, 'small')
              div(:class => 'clear')
            }
          }
        }
      else
        content_resources.each{|e|
          disable_bottom_border = @presenter.site_settings[:disable_bottom_border].include?(e.resource.resource_type.hrid)
          div(:id => sort_id(e), :class => "item#{' draft' if e.resource.status == 'DRAFT'}#{' no-bottom-border' if disable_bottom_border }") {
            sort_handle
            render_content_resource(e)
            div(:class => 'clear')
          }
        }       
      end
      content_resources
    end
  end

  def ext_title
    WidgetManager::Base.new do
      text get_name
    end
  end

  def ext_description
    WidgetManager::Base.new do
      meta_description = get_meta_description
      if meta_description.empty?
        text get_description
      else
        text meta_description
      end
    end
  end

  def ext_keywords
    WidgetManager::Base.new do
      text get_meta_keywords
    end
  end

  def ext_main_image
    WidgetManager::Base.new do
      date = get_countdown_date
      
      if date && !date.empty?
        servertime = Time.new.strftime('%B %d, %Y %H:%M:%S')
        targettime = Time.parse(Date.strptime(date, '%d.%m.%Y').to_s).strftime('%B %d, %Y 09:%M:%S')
        prefix = get_countdown_prefix
        suffix = get_countdown_suffix
        href = get_countdown_href
        div(:id => 'countdown')
        javascript {
          rawtext '$(function() {'
          rawtext "  var launchdate = new cdLocalTime('countdown', '#{servertime}', 0, '#{targettime}', '#{prefix}', '#{suffix}', '#{href}');"
          rawtext "  launchdate.displaycountdown('countdown', formatresults2);"
          rawtext '});'

        }
      elsif get_main_image && !get_main_image.empty?
        div(:class => 'image'){
          img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
          br
          text get_main_image_alt
        }
      end
    end
  end

  def ext_related_items
    resources = related_items
    WidgetManager::Base.new(helpers) do
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ box rss newsletter},:new_text => 'צור קופסא חדשה', :has_url => false, :placeholder => 'related_items', :position => 'bottom'}).render_to(self)
      show_content_resources(:parent => :content_page, :placeholder => :related_items, :resources => resources, :sortable => true)
      resources
    end
  end

  private

  def render_content_item(tree_node, view_mode)
    klass = tree_node.resource.resource_type.hrid
    return w_class(klass).new(:tree_node => tree_node, :view_mode => view_mode).render_to(self)
  end
  
  def content_resources
    if @presenter.page_params.has_key?('archive') && get_acts_as_section
      @content_resources ||= TreeNode.get_subtree(
        :parent => tree_node.id,
        :resource_type_hrids =>  ['content_page'], 
        :depth => 1,
        :has_url => true,
        :status => ['ARCHIVED']
      )
    else
      @content_resources ||= TreeNode.get_subtree(
        :parent => tree_node.id,
        :resource_type_hrids => ['article', 'content_preview', 'section_preview', 'rss', 'video', 'media_rss', 'video_gallery', 'media_casting', 'campus_form', 'iframe', 'title', 'manpower_form', 'picture_gallery', 'audio_gallery', 'newsletter'],
        :depth => 1,
        :has_url => false,
        :placeholders => ['main_content'],
        :status => ['PUBLISHED', 'DRAFT']
      )     
    end
  end

  def content_header_resources
    @content_header_resources ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['kabtv', 'admin_comment', 'map', 'errormsg', 'article'],
      :depth => 1,
      :has_url => false,
      :placeholders => ['main_content_header'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def related_items
    @related_items ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['box', 'rss', 'newsletter'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['related_items'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

end
