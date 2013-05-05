class Global::Widgets::BlockHolder < WidgetManager::Base
  
  def render_full
    debugger
    title = get_title
    block = Block.find_by_name get_block

    div(:class => 'box all-box-background') {
      div(:class => 'box-top'){rawtext('&nbsp;')}
      div(:class => 'box-mid'){
        
        h3 title unless title.empty?
        rawtext block.content unless block.nil?
        br
        w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
      }
      div(:class => 'box-bot'){rawtext('&nbsp;')}
    }
  end
  
end
