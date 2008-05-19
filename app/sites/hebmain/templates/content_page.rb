class Hebmain::Templates::ContentPage < WidgetManager::Template

  def set_layout
    layout.ext_content = ext_content
    layout.ext_title = ext_title
    layout.ext_main_image = ext_main_image
    layout.ext_related_items = ext_related_items
  end

  def ext_content
    WidgetManager::Base.new do
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button edit_button delete_button }, :resource_types => %W{ article content_preview rss },:new_text => 'צור יחידת תוכן חדשה', :has_url => false, :placeholder => 'main_content'}).render_to(self)
      unless get_acts_as_section
        h1 get_title
        h2 get_small_title
        div(:class => 'descr') { text get_sub_title }
        div(:class => 'author') {
          span'תאריך: ' + get_date, :class => 'left' unless get_date.empty?
          unless get_writer.empty?
            span(:class => 'right') {
              text 'מאת: '
              unless get_writer_email.empty?
                a(:href => 'mailto:' + get_writer_email){
                  img(:src => img_path('email.gif'), :alt => 'email')
                  text ' ' + get_writer
                }
              else
                text ' ' + get_writer
              end
            }
          end
        }
      end
      unless get_body.empty?
        div(:class => 'item') {
          rawtext get_body
        }
      end
      # debugger
      content_resources.each{|e|
        div(:class => 'item') {
          render_content_resource(e)
          div(:class => 'clear')
        } 
      }
      # div(:class => 'item') {
      #   div(:class => 'section_preview') {
      #     div(:class => 'h1') {
      #       text 'פסח'
      #       img(:src => img_path('sec-right.gif'),:class =>'h1-right', :alt => '')
      #       img(:src => img_path('sec-left.gif'),:class =>'h1-left', :alt => '')
      #     }
      #     div(:class => 'element preview-odd'){
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:class => 'img', :src => img_path('pesah-p1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'element preview-even'){
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:class => 'img', :src => img_path('pesah-p1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'footer') {
      #       a(:class => 'left') {
      #         text 'לארכיון הכתבות בנושא'
      #         img(:src => img_path('arrow-left.gif'), :alt => '')
      #       }
      #     }
      #   }
      # }
      # div(:class => 'item') {
      #   div(:class => 'main_preview2') {
      #     div(:class => 'element') {
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:style => 'width:204px', :src => img_path('apple-tree-preview1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'element last') {
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:style => 'width:204px', :src => img_path('apple-tree-preview1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'clear')
      #   }
      # }
      # 
      # div(:class => 'item') {
      #   div(:class => 'main_preview3') {
      #     div(:class => 'element') {
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:src => img_path('pesah-p1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'element') {
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:src => img_path('pesah-p1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'element last') {
      #       h1 'ט"ו בשבט - חג המקובלים'
      #       div(:class => 'descr') { text 'ט"ו בשבט מביא עִמו את תחילתה של העונה הקסומה ביותר בשנה. האוויר הופך צלול, השמים מתבהרים וקרני השמש חודרות מבעד לצמרות העצים. החורף כמעט חלף והאביב נראה בפתח. '}
      #       div(:class => 'author') {
      #         span'תאריך: ' + '04.03.2008', :class => 'right' #unless get_date.empty?
      #         a(:class => 'left') { text "...לכתבה" }
      #       }
      #       img(:src => img_path('pesah-p1.jpg'), :alt => 'preview')
      #     }
      #     div(:class => 'clear')
      #   }
      # }


    end
  end

  def ext_title
    WidgetManager::Base.new do
      text get_name
    end
  end

  def ext_meta_title
    WidgetManager::Base.new do
      text get_name# unless get_hide_name
    end
  end

  def ext_main_image
    WidgetManager::Base.new do
      div(:class => 'image'){
        img(:src => get_main_image, :alt => get_main_image_alt, :title => get_main_image_alt)
        text get_main_image_alt
      }
    end
  end

  def ext_related_items
    WidgetManager::Base.new do
      w_class('cms_actions').new(:tree_node => @tree_node, :options => {:buttons => %W{ new_button }, :resource_types => %W{ box },:new_text => 'צור קופסא חדשה', :has_url => false, :placeholder => 'related_items', :position => 'bottom'}).render_to(self)
      related_items.each{|e|
        render_related_item(e)
      }  
    end
  end

  private

  def render_content_resource(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    w_class(class_name).new(:tree_node => tree_node).render_to(self)
  end

  def content_resources
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['article', 'content_preview', 'rss'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['main_content'],
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end

  def render_related_item(tree_node)
    class_name = tree_node.resource.resource_type.hrid
    return w_class(class_name).new(:tree_node => tree_node, :view_mode => 'related_items').render_to(self)
  end

  def related_items
    TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['box'], 
      :depth => 1,
      :has_url => false,
      :placeholders => ['related_items'],
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end


end