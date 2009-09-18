class Global::Widgets::AdminComment < WidgetManager::Base
  require 'parsedate'
  include ParseDate

  def render_full
    create_main_div if tree_node.can_edit?
  end
  
  def render_update_comment
    cm = Comment.find(@options['cid'])
    cm.update_attribute('title', @options['title'])
    cm.update_attribute('body', @options['body'])
    write_inside_of_form
  end
  
  def render_moderate_comment
    unless @options['filter'].blank?
      action_hash= {'node_id' => @options['widget_node_id'], 'validate' => {}, 'delete' => [], 'cache' => []}
      @options.each{|op|
        is_action = op[0].include? "action"
        if is_action
          id = op[0].split('action')[1]
          page_id = op[0].split('action')[0]
          action_hash['cache'].push(page_id) unless action_hash['cache'].include?(page_id)
          action_value = op[1]
          case action_value
          when 'validate' then
            action_hash[action_value].store(id, {'is_valid' => '200'})
          when 'invalidate' then
            action_hash['validate'].store(id, {'is_valid' => '500'})
          when 'delete' then
            action_hash[action_value].push(id)
          end
        end
      }
      Comment.delete(action_hash['delete'])
      Comment.update(action_hash['validate'].keys, action_hash['validate'].values )
      action_hash['cache'].each{|c|
        FileUtils.rm(Dir['tmp/cache/tree_nodes/'+c+'-*']) rescue Errno::ENOENT
      }
    end
    write_inside_of_form
  end

  private


  def write_links_of_page(total = 0, offset = 1, cat = 'nil', mod = 'off')
    cat = 'nil' if cat.blank?
    nb_page = (total / offset)
    index = 0
    while nb_page > index
      index += 1
      a(:href => get_page_url(@presenter.node) + '?page_nb=' + index.to_s + '&cat=' + cat + '&mod=' + mod){
        text ' <' + index.to_s + '> '
      }
    end
  end


  def create_main_div
    div(:class => 'admin_comments'){
      h3 get_name
      w_class('cms_actions').new(:tree_node => tree_node, :options => {
          :buttons => %W{ delete_button edit_button},
          :button_text => _(:admin_comments)
        }).render_to(self)

      input :type=>"button", :value=>_(:reload),
      :onclick=>"window.location.href=window.location.href.split('?')[0]"
      br
      div(:class => 'admin_comment_main'){
        form(:id => 'admin_comment_form') {
          if @presenter.page_params[:comment_id].blank?
            write_inside_of_form
          else
            single_comment(@presenter.page_params[:comment_id])
          end
        }
      }
    }
  end

  def write_inside_of_form
    cat =  @presenter.main_sections
    p{
      br
      input :type => 'checkbox', :name => 'options[onlymoderated]'
      text ' '
      text _(:non_moderated)
      br
      
      input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => _(:submit)
      input :type => 'reset', :name => 'Cancel', :id => 'cancel', :class => 'submit', :value => _(:cancel)
      input :type => 'hidden', :name => 'view_mode', :value => 'moderate_comment'
      input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
      input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
      
      select(:name => 'options[filter]'){
        option(:value => "nil"){text _(:all)}
        cat.each{|c|
          option(:value => c.id ){text c.resource.name}
        }
      }

      
      table{
        thead{
          tr{
            th _(:page)
            th _(:date)
            th _(:valid)
            th _(:spam)
            th _(:name)
            th _(:title)
            th _(:body)
            th _(:edit)
            th(:colspan => '2'){text _(:valid)}
            th _(:del)
          }
        }
        
        
        if @presenter.page_params.include?('options')
          cat = @options['filter']
          mod = @options['onlymoderated']
          page = 1
        else
          page = @presenter.page_params[:page_nb].blank? ? 1 : @presenter.page_params[:page_nb].to_i
          cat = @presenter.page_params[:cat].blank? ? 'nil' : @presenter.page_params[:cat]
          mod = @presenter.page_params[:mod].blank? ? 'off' : @presenter.page_params[:mod]
        end

        mod = (mod.blank? || mod == 'off') ?  'off' : 'on'

        if mod == 'on'
          if cat == 'nil'
            hash_comment = Comment.list_all_non_moderated_comments(page, @presenter.website_node)
          else
            hash_comment = Comment.list_non_moderated_comments_for_category(cat, page, @presenter.website_node)
          end
        else
          if cat  == 'nil'
            hash_comment = Comment.list_all_comments(page, @presenter.website_node)
          else
            hash_comment = Comment.list_all_comments_for_category(cat, page, @presenter.website_node)
          end
        end
        
        comment_list = hash_comment['content_arrays']
        comment_count = hash_comment['count_comments']
        comment_list.each_with_index { |cl,i|
          cmcreated = parsedate cl.created_at.to_s
          case cl.is_valid
          when 0 then klass = 'notmod'
          when 500 then klass = 'badmod'
          else  klass = 'modok'
          end
          tr(:class => klass){
            td(:class => 'title'){a(:href => '/kabbalah/short/'+cl.tree_node_id.to_s){text TreeNode.find(cl.tree_node_id).resource.name}}
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
              input :type=>'radio', :name => 'options['+cl.tree_node_id.to_s+'action'+cl.id.to_s+']', :value => 'validate'
            }
            td(:class => 'red'){
              input :type=>'radio', :name => 'options['+cl.tree_node_id.to_s+'action'+cl.id.to_s+']', :value => 'invalidate'
            }
            td(:class => 'funct'){
              input :type=>'radio', :name => 'options['+cl.tree_node_id.to_s+'action'+cl.id.to_s+']', :value => 'delete'
            }
          }
          break unless i < (page*Comment::NBCOMMENTPERPAGE)
        }
        tr{td(:colspan => 11 ){
            write_links_of_page(comment_count, Comment::NBCOMMENTPERPAGE, cat, mod)
          }}
      }
    }
  end



  def single_comment(cid = 0)
    cm = Comment.find(cid)
    p(:class => 'right'){
      text _(:title)+': '
      input  :type => 'text', :name => 'options[title]', :value => cm.title
      br
      br
      text _(:body)+': '
      textarea(:cols => '10', :rows =>'15', :name => 'options[body]'){text cm.body}
      br
      br
      input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
      input :type => 'button', :name => 'Cancel', :id => 'cancel', :class => 'submit',
      :onClick=>"$(this).replaceWith(\"<div id='loader'>&nbsp;&nbsp;<img class='tshuptshik' alt='Loading' src='/images/ajax-loader.gif'></div>\");window.location.href=window.location.href.split('?')[0]",
      :value => 'בטל'
      input :type => 'hidden', :name => 'view_mode', :value => 'update_comment'
      input :type => 'hidden', :name => 'options[cid]', :value => cid
      input :type => 'hidden', :name => 'options[widget]', :value => 'admin_comment'
      input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
    }
  end

 

end
