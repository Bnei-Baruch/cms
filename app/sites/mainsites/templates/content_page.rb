class Mainsites::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_content_header = ext_content_header
    layout.ext_title = ext_title
    layout.ext_description = ext_description
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
    layout.ext_kabtv_exist = ext_kabtv_exist
  end

  def ext_kabtv_exist
    !content_header_resources.blank?
  end
  
  def ext_content_header
    WidgetManager::Base.new(helpers) do
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ new_button },
          :resource_types => %W{ kabtv },
          :button_text => _(:'upper_part_admin'),
          :new_text => _(:'create_new_content_item'),
          :has_url => false, :placeholder => 'main_content_header'}).render_to(self)
      if AuthenticationModel.current_user_is_admin?
        w_class('cms_actions').new(:tree_node => @tree_node,
          :options => {:buttons => %W{ new_button },
            :resource_types => %W{ admin_comment },
            :button_text => _(:'admin'),
            :new_text => _(:'create_modul_comments_administration'),
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
      w_class('cms_actions').new(:tree_node => @tree_node,
        :options => {:buttons => %W{ new_button edit_button },
          :resource_types => %W{ article content_preview section_preview rss video media_rss video_gallery media_casting campus_form iframe title manpower_form picture_gallery audio_gallery newsletter},
          :button_text => _(:'content_page_management'),
          :new_text => _(:'create_new_content_item'),
          :edit_text => _(:'edit_content_page'),
          :has_url => false, :placeholder => 'main_content'}).render_to(self)

      unless get_acts_as_section
        div(:class => 'h1') {
          div(:class => 'left-ear')
          div(:class => 'right-ear')
          h1 get_title
        }
        small_title = get_small_title
        h2 get_small_title unless small_title.empty?
        sub_title = get_sub_title
        div(:class => 'descr') {
          div(:class => 'left-ear')
          div(:class => 'right-ear')
          text sub_title
        } unless sub_title.empty?
        my_date = get_date
        writer = get_writer
        unless my_date.empty? && writer.empty?
          div(:class => 'author') {
            span _(:'date') + ': ' + my_date, :class => 'left' unless my_date.empty?
            unless writer.empty?
              span(:class => 'left') {
                text _(:'writer') + ': ' + writer
                unless get_writer_email.empty?
                  a(:href => 'mailto:' + get_writer_email){
                    img(:src => img_path('email.gif'), :alt => 'Email to')
                  }
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
      div(:id => 'content_resources'){
        content_resources.each{|e|
          disable_bottom_border = @presenter.site_settings[:disable_bottom_border].include?(e.resource.resource_type.hrid)
          div(:id => sort_id(e), :class => "item#{' draft' if e.resource.status == 'DRAFT'}#{' no-bottom-border' if disable_bottom_border }") {
            sort_handle
            render_content_resource(e)
            div(:class => 'clear')
          }
        }
      }
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
      text get_description
    end
  end

  def ext_meta_title
    WidgetManager::Base.new do
      #  text get_name# unless get_hide_name
      w_class('breadcrumbs').new(:view_mode => 'meta_title')
    end
  end

  def ext_main_image
    WidgetManager::Base.new do
      if get_main_image && !get_main_image.empty?
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
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ box rss newsletter},:new_text => _(:'create_new_box'), :has_url => false, :placeholder => 'related_items', :position => 'bottom'}).render_to(self)
      show_content_resources(:parent => :content_page, :placeholder => :related_items, :resources => resources, :sortable => true)
      resources
    end
  end

  private

  def content_resources
    @content_resources ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['article', 'content_preview', 'section_preview', 'rss', 'video', 'media_rss', 'video_gallery', 'media_casting', 'campus_form', 'iframe', 'title', 'manpower_form', 'picture_gallery', 'audio_gallery', 'newsletter'],
      :depth => 1,
      :has_url => false,
      :placeholders => ['main_content'],
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  def content_header_resources
    @content_header_resources ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['admin_comment'],
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
