class Global::Widgets::BlockHolder < WidgetManager::Base

  def render_full
    title = get_title
    block = Block.find_by_name get_block

    div() {
      div(){rawtext('&nbsp;')}
      div(){

        h3 title unless title.empty?
        rawtext block.content unless block.nil?
        br
        w_class('cms_actions').new(:tree_node => tree_node, :options => {:buttons => %W{ delete_button  edit_button }}).render_to(self)
      }
      div(){rawtext('&nbsp;')}
    }
  end

end
