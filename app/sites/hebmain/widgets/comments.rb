class Hebmain::Widgets::Comments < WidgetManager::Base
  require 'parsedate'
  include ParseDate
   
  def initialize(*args, &block)
    super
  #  @presenter.disable_cache
  end
  
  def render_full
    write_trigger
    write_create_div
    write_previous_comments
  end
  
  def render_new_comment
    @akismet = Akismet.new('002dac05fca4e3', 'http://hebrew.localhost:3000/') 
    #akismet_api = true unless @akismet.verifyAPIKey 
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
    
    
    ppt = @tree_node.parent
    pt = @tree_node
    while ppt.id != @presenter.website_node.id
      ppt = ppt.parent
      pt = pt.parent
    end 
    categ = pt.id
    
    
    new_comment = Comment.new(:title => @options[:title], :name => @options[:name],:email => @options[:email], :body => @options[:body], :node_id => @options[:widget_node_id], :is_spam => is_spam, :is_valid => false, :category => categ)
    new_comment.save!
    
    write_effect_yellow(@options[:name])
    write_create_form
    
    #@akismet.commentCheck(@presenter.controller.request.remote_ip, @presenter.controller.request.user_agent, @presenter.controller.request.env['HTTP_REFERER'],  '', 'comment', @options[:name], @options[:email],'', @options[:body], {})  
   
  end

  private
  
  def write_effect_yellow(name)
    div(:id => 'yellow_effect'){
      text " תודה #{name}"
      br
      text "תגובתך התקבלה,"
      br
      text "ותפורסם בקרוב, בהתאם לשיקולי המערכת. "
    }
  end

  def write_create_div
    div(:class => 'create_comment'){
      div(:id => 'create_comment_div'){
        form(:id => 'comment_form', :method => 'post'){
          write_create_form
        }
      }
    }
  end
  
  def write_create_form
      table(:id => 'reactions'){
        tr{
          td(:colspan => '2'){
              h1{text _('Reactions')}
            }
        }
        tr{
          td{label(:for => 'title'){text _('Title')}}
          td{input :type => 'text', :id => 'title', :name => 'options[title]',  :size => '31', :class => 'text'}
        }    
        tr{
          td{label(:for => 'name'){text _('Name')}}
          td{input :type => 'text', :id => 'name', :name => 'options[name]',  :size => '31', :class => 'text'}
        }
        tr{
          td{label(:for => 'email'){text _('Email')}}
          td{input :type => 'text', :id => 'email',:name => 'options[email]', :size => '31', :class => 'text'}
        }
        tr{
          td(:id => 'content'){label(:for => 'options_body'){text _('Body')}}
          td{textarea :cols => '50', :rows => '6',:id => 'options_body', :name => 'options[body]', :class => 'text'}
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
    counter_for_comments = comment_list.size
    div(:class => 'comment_header'){text _('Reactions')} if counter_for_comments > 0
    comment_list.each { |cl|
      cmcreated = parsedate cl.created_at.to_s
      div(:class => 'comment_item'){
        div(:class => 'comment_title'){
          if cl.body.blank?
            rawtext "#{counter_for_comments}. #{cl.title}"
            rawtext ' (לת)' 
          else
            span(:class => "comment_clickable"){rawtext "#{counter_for_comments}. #{cl.title}"}
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
        div(:class => 'comment_body'){text cl.body} unless cl.body.blank?
      }
      counter_for_comments -=  1 
    }
  end
  

  
end
