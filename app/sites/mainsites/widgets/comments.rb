class Mainsites::Widgets::Comments < WidgetManager::Base
  require 'parsedate'
  include ParseDate
   
  def initialize(*args, &block)
    super
  end
  
  def render_full
    div(:id => 'closed_comment',
      :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/services.gif)"){
      span(:class => 'link_comment'){
        text _(:add_comment)
      }
    }
    div(:id => 'create_comment'){
      write_create_form
    }
  end
  
  def render_previous
    write_previous_comments
  end
  
  
  def render_new_comment
    @akismet = Akismet.new('2dac05fca4e3', 'http://kab.co.il/') 
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
    
    
    new_comment = Comment.new(:title => @options[:title], :name => @options[:name],:email => @options[:email], :body => @options[:body], :tree_node_id => @options[:widget_node_id], :is_spam => is_spam, :is_valid => false, :category => categ)
    new_comment.save!
    
    write_effect_yellow(@options[:name])
    write_create_form
  end

  private
  
  def write_effect_yellow(name)
    div(:id => 'yellow_effect'){
      text _(:thanks) + " #{name}"
      br
      text _(:comment_received) + ","
      br
      text _(:will_be_published)
    }
  end

  def write_create_form
    form(:id => 'comment_form', :method => 'post', :action => get_page_url(@presenter.node)){
      table(:id => 'reactions'){
        tr{
          td(:colspan => '2'){
            div(:class => 'h-h1') {text _(:comments)}
          }
        }
        tr{
          td(:class => 'text'){span _(:title)}
          td(:class => 'input'){input :type => 'text', :id => 'title', :name => 'options[title]',  :size => '31'}
        }
        tr{
          td(:class => 'text'){span _(:name)}
          td(:class => 'input'){input :type => 'text', :id => 'name', :name => 'options[name]',  :size => '31'}
        }
        tr{
          td(:class => 'text'){span _(:email)}
          td(:class => 'input'){input :type => 'text', :id => 'email',:name => 'options[email]', :size => '31'}
        }
        tr{
          td(:id => 'content', :class => 'text'){span _(:body)}
          td(:class => 'input'){
            textarea :cols => '50', :rows => '6',:id => 'options_body', :name => 'options[body]'
            input :type => 'hidden', :name => 'view_mode', :value => 'new_comment'
            input :type => 'hidden', :name => 'options[widget]', :value => 'comments'
            input :type => 'hidden', :name => 'options[widget_node_id]', :value => tree_node.id
          }
        }
        
        
        tr{
          td{}
          td{
            a(:id => 'submit',
              :class => 'submit',
              :onclick => '$("#comment_form").submit();return false;',
              :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/button.gif)") {
              rawtext _(:send)
            }
            a(:id => 'cancel',
              :class => 'submit',
              :style => "background-image:url(/images/#{@presenter.site_settings[:site_name]}/button.gif)") {
              rawtext _(:cancel)
            }
          }
        }
      }
    }
  end
  
  def write_previous_comments
    comment_list = Comment.list_all_comments_for_page(tree_node.id)
    counter_for_comments = comment_list.size
    div(:class => 'comment_header'){text _(:comments)}
    if counter_for_comments == 0
      div(:class => 'comment_empty'){text _(:there_are_no_comments_so_far)}
    end
    comment_list.each { |cl|
      cmcreated = parsedate cl.created_at.to_s
      div(:class => 'comment_item'){
        div(:class => 'comment_title'){
          if cl.body.blank?
            rawtext "#{counter_for_comments}. #{cl.title}"
            rawtext ' ' + _(:without_content)
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
