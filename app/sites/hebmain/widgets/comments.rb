class Hebmain::Widgets::Comments < WidgetManager::Base
  require 'parsedate'
  include ParseDate
   
  def render_full
    @presenter.disable_cache
    
    write_trigger
    write_create_div
    write_previous_comments
       
  end

  def write_create_div
    div(:class => 'create_comment'){
      div(:id => 'create_comment_div'){
        form(:id => 'comment_form'){
          write_create_form
        }
      }
    }
  end
  
  def write_create_form
          p{
            table{
              tr{
                td{label(:for => 'title'){text _('Title')}}
                td{input :type => 'text', :id => 'title', :name => 'options[title]', :value => "Title", :size => '31', :class => 'text'}
              }
               
              tr{
                td{label(:for => 'name'){text _('Name')}}
                td{input :type => 'text', :id => 'name', :name => 'options[name]', :value => "Name", :size => '31', :class => 'text'}
              }
              tr{
                td{label(:for => 'email'){text _('Email')}}
                td{input :type => 'text', :id => 'email',:name => 'options[email]', :value => "Email", :size => '31', :class => 'text'}
              }
              tr{
              td{label(:for => 'body'){text _('Body')}}
              td{textarea :cols => '30', :rows => '6', :name => 'options[body]', :size => '31', :class => 'text'}
              }
              input :type => 'hidden', :name => 'view_mode', :value => 'new_comment'
              input :type => 'hidden', :name => 'options[widget]', :value => 'comments'
              input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
              tr{
              td{text ' '}
              td{
                input :type => 'submit', :name => 'Submit', :id => 'submit', :class => 'submit', :value => 'שלח'
                input :type => 'reset', :name => 'Cancel', :id => 'cancel', :class => 'submit', :value => 'בטל'
              }
            }      
        }
        br           
      }
  end
  
  def write_trigger
    span(:id => 'closed_comment'){
        img(:src => "/images/plus.jpg", :alt => 'הוסף תגובה ')
        span(:class => 'link_comment'){
          text 'הוסף תגובה '
        }
      }
  end
  
  def write_previous_comments
    
    comment_list = Comment.list_all_comments_for_page(tree_node.id)
    i = comment_list.size
    debugger
    div(:class => 'comment_header'){text _('Reactions')} if i > 0
    comment_list.each { |cl|
      cmcreated = parsedate cl.created_at.to_s
      div(:class => 'comment_item'){
        div(:class => 'comment_title'){
          unless cl.body == ""
            span(:class => "comment_clickable"){text i.to_s+". "+cl.title}
          else
            text i.to_s+". "+cl.title
            text ' (לת)' 
          end
          
          }
        
        br
        text cl.name+', '
        text cmcreated[2]
        text "."
        text cmcreated[1]
        text "."
        text cmcreated[0].to_s[2,3]
        text ' '
        text cmcreated[3].to_s+':'+cmcreated[4].to_s
        div(:class => 'comment_body'){text cl.body} unless cl.body == ''
      }
      i = i - 1 
    }
  end
  
  def render_new_comment
    @presenter.disable_cache   
    @akismet = Akismet.new('002dac05fca4e3', 'http://hebrew.localhost:3000/') 
    akismet_api = true unless @akismet.verifyAPIKey 
    is_spam = @akismet.commentCheck(
               @presenter.controller.request.remote_ip,            # remote IP
               @presenter.controller.request.user_agent,           # user agent
               @presenter.controller.request.env['HTTP_REFERER'],  # http referer
               '',                           # permalink
               'comment',                    # comment type
               @options[:name],                       # author name
               @options[:email],                           # author email
               '',                           # author url
               @options[:body],                         # comment text
            {})  
      
   new_comment = Comment.new(:title => @options[:title], :name => @options[:name],:email => @options[:email], :body => @options[:body], :node_id => @options[:widget_node_id], :is_spam => is_spam, :is_valid => false)
	 new_comment.save
   
   write_create_form

   #@akismet.commentCheck(@presenter.controller.request.remote_ip, @presenter.controller.request.user_agent, @presenter.controller.request.env['HTTP_REFERER'],  '', 'comment', @options[:name], @options[:email],'', @options[:body], {})  
   
  end
  
end
