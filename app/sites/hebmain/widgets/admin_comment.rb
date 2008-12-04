class Hebmain::Widgets::AdminComment < WidgetManager::Base
  require 'parsedate'
  include ParseDate

def render_full
  @presenter.disable_cache
  create_main_div  
end

def create_main_div
  @presenter.disable_cache
  div(:class => 'admin_comment_main'){
  form(:id => 'admin_comment_form') {
  if params[:comment_id] != nil
    single_comment(params[:comment_id])
  else
    write_inside_of_form
  end
      
    }
  }
end

def write_inside_of_form
  p{
    input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
    input :type => 'reset', :name => 'Cancel', :id => 'cancel', :class => 'submit', :value => 'בטל'
    input :type => 'hidden', :name => 'view_mode', :value => 'moderate_comment'
    input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
    input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
    
    b{'Admin comment'}
    table{
      thead{
        tr{
          th 'Page'
          th 'Date'
          th 'Valid'
          th 'Spam'
          th 'Name'
          th 'Title'
          th 'Body'
          th 'Edit'
          th(:colspan => '2'){text 'Valid'}
          th 'Del'
        }
      }

      comment_list = Comment.list_all_comments
      comment_list.each { |cl|
        cmcreated = parsedate cl.created_at.to_s  
        if cl.is_valid == 0
          klass = 'notmod'
        else
          if cl.is_valid == 500
            klass = 'badmod'
          else
            klass = 'modok'
          end
        end
        tr(:class => klass){
            td(:class => 'title'){a(:href => '/kabbalah/short/'+cl.node_id.to_s){text TreeNode.find(cl.node_id).resource.name}}
            td(:class => 'title'){ #date
              text cmcreated[2]
              text "."
              text cmcreated[1]
              text "."
              text cmcreated[0].to_s[2,3]
            }
            td(:class => 'valid'){text cl.is_valid}
            td(:class => 'spam'){text cl.is_spam}
            td(:class => 'title'){text cl.name}
            td(:class => 'title'){text cl.title}
            td(:class => 'body'){text cl.body}
            td(:class => 'funct'){
              a(:href => get_page_url(@presenter.node)+'?comment_id='+cl.id.to_s){text 'Edit'}
            }
            #valid
            td(:class => 'green'){
             input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'validate'
            }
            td(:class => 'red'){
             input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'invalidate'
            }
            td(:class => 'funct'){
              input :type=>'radio', :name => 'options[action'+cl.id.to_s+']', :value => 'delete'
            }
          }
        }
      }
   }
end

def render_moderate_comment
  action_hash= {'node_id' => @options['widget_node_id'], 'validate' => {}, 'delete' => []}
  @options.each{|op|
   is_action = op[0].include? "action"
   if is_action
     id = op[0].split('action')[1]
     action_value = op[1]
     if action_value == 'validate'
       action_hash[action_value].store(id, {'is_valid' => '200'})
     end
     if action_value == 'invalidate'
       action_hash['validate'].store(id, {'is_valid' => '500'})
     end
     if action_value == 'delete'
       action_hash[action_value].push(id)
     end
   end
  }
 Comment.delete(action_hash['delete'])
 Comment.update(action_hash['validate'].keys, action_hash['validate'].values )
 
 write_inside_of_form
 
end

def single_comment(cid = 0)
  cm = Comment.find(cid)
    p(:class => 'right'){
      text _('Title')+': '
      input  :type => 'text', :name => 'options[title]', :value => cm.title
      br
      br
      text _('Body')+': '
      textarea(:cols => '10', :rows =>'15', :name => 'options[body]'){text cm.body}
      br
      br
      input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
      input :type => 'hidden', :name => 'view_mode', :value => 'update_comment'
      input :type => 'hidden', :name => 'options[cid]', :value => cid
      input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
      input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
    }
end

def render_update_comment
  cm = Comment.find(@options['cid'])
  cm.update_attribute('title', @options['title'])
  cm.update_attribute('body', @options['body'])
  write_inside_of_form
end

end
