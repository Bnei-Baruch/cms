class Global::Widgets::CmsActions < WidgetManager::Base
  @@idx = 0  
  # tree_node - is the node object to which the operations will be performed. Editing will be for this object, New is a new child for this object, Delete is deleting this tree_node
  def render_full
    # return rawtext('') if AuthenticationModel.current_user_is_anonymous? || !tree_node.can_create_child?
    # operations permitted only on tree nodes other than the page you are on now.
    buttons = []
    if @options
      if tree_node.can_create_child? && @options[:buttons].include?('new_button')
        buttons << 'new_button'
      end
      if tree_node.can_edit? && @options[:buttons].include?('edit_button')
        buttons << 'edit_button'
      end
      if tree_node.can_delete? && @options[:buttons].include?('delete_button')
        buttons << 'delete_button'
      end
    end
    unless buttons.empty?
      @@idx += 1
      func = @options[:mode].eql?('inline') ? 'span' : 'div'
      element = "#{func}_#{@@idx}"
      #      position = @options[:position] || 'top'
      javascript{
        rawtext <<-CMS1
        Ext.onReady(function(){
            var menu = new Ext.menu.Menu({
                      items:[
        CMS1
      
        was_created = false
        buttons.each_with_index {|b, idx|
          rawtext ',' if was_created
          was_created = self.send(b, element)
        }
      
        rawtext <<-CMS2
                      ]
                  });
            var button = new Ext.Button({
              renderTo: '#{element}',
              text: '#{@options[:button_text]}',
              tooltip:'#{@options[:tooltip]}',
              iconCls:'button-menu',
              menu:menu
            });
            button.on('mouseover', function(button, event){
              button.el.parent().parent().addClass('highlight');
            });
            button.on('mouseout', function(button, event){
              button.el.parent().parent().removeClass('highlight');
            });
        });
        CMS2
      }
      self.send(func, :id => "#{element}", :class => 'span_admin', :style => @options[:style])
    end         
  end

  def new_button(element)
    parent_id = tree_node.id
    resource_types = []
    @options[:resource_types].each{|e|
      if rt = ResourceType.get_resource_type_by_hrid(e)
        resource_types << rt
      end
    }
    is_main = @options[:is_main] || true
    has_url = @options[:has_url]
    placeholder = @options[:placeholder] || ''
    new_text = @options[:new_text] || _(:new)
    if parent_id && !resource_types.empty?
      if resource_types.size > 1
        new_button_form(resource_types, parent_id, is_main, has_url, placeholder, new_text)
      else
        new_button_link(resource_types, parent_id, is_main, has_url, placeholder, new_text)
      end
      true
    else
      false
    end
  end

  def edit_button(element)
    href = edit_admin_resource_path(:id => tree_node.resource,
      :tree_id => tree_node.id,
      :slang => @presenter.site_settings[:short_language])
    text = @options[:edit_text] || _(:edit)
    rawtext <<-EDIT
      {
        text: '#{text}',
        href: '#{href}'
      }
    EDIT
    true
  end

  def delete_button(element)
    name = tree_node.resource.name.gsub(/'/,'&#39;')
    text = @options[:delete_text] || _(:delete)
    rawtext <<-DELETE
      {
        text: '#{text}',
        handler: function (item) {
          Ext.Msg.confirm('#{name}', 'Are you sure you want to delete<br/><#{name}>?',
            function(e){
              if(e == 'yes') {
                Ext.Ajax.request({
                  url: '#{tree_node_delete_admin_tree_node_path(tree_node)}',
                  method: 'post',
                  params: {elem:'#{element}'},
                  callback: function (options, success, responce){
                    if (success) {
                      Ext.Msg.alert('#{name}', 'The item was successfully deleted');
                      Ext.get('#{element}').parent().remove();
                    } else {
                      Ext.Msg.alert('#{name}', 'FAILURE: ' + responce.status + ' ' + responce.statusText);
                    }
                  }
                });
              }
            }
          )
        }
      }
    DELETE
    true
  end

  
  def render_tree_drop_zone
    unless AuthenticationModel.current_user_is_anonymous?
      if tree_node.can_create_child?
        widget_id = tree_node.id
        widget_name = tree_node.resource.resource_type.hrid
        if tree_node.can_edit? && @options[:page_url] && @options[:updatable]
          page_url = @options[:page_url]
          updatable = @options[:updatable]
          updatable_view_mode = @options[:updatable_view_mode]
          javascript() {
            rawtext <<-EXT_ONREADY
            Ext.onReady(function(){
              tree_drop_zone("#{widget_id}", "#{page_url}", "#{widget_name}", "#{updatable}", "#{updatable_view_mode}");
              });
            EXT_ONREADY
          }
          div(:id => "dz-#{widget_id}", :class => 'drop-zone')
        end
      end
    end
  end


  private

  def new_button_link(resource_types, parent_id, is_main, has_url, placeholder, new_text = nil)
    href = new_admin_resource_path(
      :resource => {
        :resource_type_id => resource_types.first.id, 
        :tree_node => {:parent_id => parent_id,
          :is_main => is_main,
          :has_url => has_url,
          :placeholder => placeholder
        },
        :slang => @presenter.site_settings[:short_language]
      }
    )
    new_text ||= 'צור חדש'
    rawtext <<-NEW_LINK
      {
        text: '#{new_text}',
        href: '#{href}'
      }
    NEW_LINK
  end

  def new_button_form(resource_types, parent_id, is_main, has_url, placeholder, new_text = nil)
    new_text ||= 'צור חדש'
    rawtext <<-NEW_LINK1
      {
        text: '#{new_text}',
        menu: {
          items: [
            '<b>Select a Resource to create</b>',
    NEW_LINK1

    resource_types.sort{ |a,b| a.name <=> b.name }.each_with_index{ |e, idx|
      href = new_admin_resource_path(
        :slang => @presenter.site_settings[:short_language],
        :resource => {
          :resource_type_id => e.id, 
          :tree_node => {:parent_id => parent_id,
            :is_main => is_main,
            :has_url => has_url,
            :placeholder => placeholder}
        }
      )
      rawtext ',' unless idx.eql?(0)
      rawtext "{text:'#{e.name}', href:'#{href}'}"
    }

    rawtext <<-NEW_LINK2
          ]
        }
      }
    NEW_LINK2
  end

end
