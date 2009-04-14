class Global::Widgets::Header < WidgetManager::Base

  def render_search
    search_page = domain + '/' + presenter.controller.website.prefix + '/' + 'search'
    id = options[:id] rescue '011301558357120452512:ulicov2mspu' # hebrew search

    form(:action => search_page, :id => 'cse-search-box'){
      div(:id => 'search'){
        input :type => 'text', :name => 'q', :size => '31', :class => 'text'
        div :class => 'prebutton'
        input :name => "sa", :class => "submit button", :value => _(:search), :type => "submit", :title => _(:search), :alt => _(:search)
        div :class => 'postbutton'
        div :class => 'clear'
        input :type => 'hidden', :name => 'cx', :value => id
        input :type => 'hidden', :name => 'ie', :value => 'UTF-8'
        input :type => 'hidden', :name => 'cof', :value => 'FORID:11'
      }
      # Delay execution
      # <script type="text/javascript" src="http://www.google.com/coop/cse/brand?form=cse-search-box&amp;lang=he"></script>
      javascript {
        rawtext <<-google
$(document).ready(function(){
  $.ajax({
     type: "GET",
     url: "http://www.google.com/coop/cse/brand",
     data: {form:'cse-search-box', lang:'he'},
     dataType: "script",
     cache: true
  });
});
        google
      }
    }
  end

  def render_top_languages
    div(:id => 'lang'){
      w_class('cms_actions').new(:tree_node => presenter.website_node,
        :options => {
          :buttons => %W{ new_button },
          :resource_types => %W{ language },
          :new_text => _(:new_language),
          :has_url => false,
          :placeholder => 'top_languages',
          :mode => 'inline',
          :style => 'float:right'
        }).render_to(self)
      if (@options && @options[:simple])
        rawtext _(:languages)
        rawtext ':'
        languages.each{|l|
          w_class('link').new(:tree_node => l, :view_mode => 'language_link').render_to(self)
        }
      else
        select(:id => 'languages',
          :onchange => 'value=this.options[this.selectedIndex].value; if (value != 0) top.location=value;'){
          option{rawtext _(:choose_your_language)}
          languages.each{|l|
            w_class('link').new(:tree_node => l, :view_mode => 'language_option').render_to(self)
          }
        } unless languages.blank?
      end
    }
  end

  def render_top_links_ext
    render_top_links(top_links_ext, 'ext')
  end

  def render_top_links_int
    render_top_links(top_links_int, 'int')
  end

  def render_top_links_simple
    links = top_links_int
    div(:id => "top_links_int") {
      w_class('cms_actions').new(:tree_node => presenter.website_node,
        :options => {
          :buttons => %W{ new_button },
          :resource_types => %W{ link },
          :new_text => _(:new_internal_link),
          :has_url => false,
          :placeholder => "top_links_int",
          :mode => 'inline'}).render_to(self)
      span(:class => 'bullet_blue')
      links.each { |e|
        span(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e).render_to(self)
        }
        span(:class => 'bullet_blue')
      }
    } unless links.blank?

    links
  end

  def render_top_links(links, ext)
    w_class('cms_actions').new(:tree_node => presenter.website_node,
      :options => {
        :buttons => %W{ new_button },
        :resource_types => %W{ link },
        :new_text => _(ext == 'ext' ? :new_external_link : :new_internal_link),
        :has_url => false,
        :placeholder => "top_links_#{ext}",
        :mode => 'inline'}).render_to(self)
    ul(:class => "links_#{ext}") {
      links.each { |e|
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e, :view_mode => 'with_image').render_to(self)
        }
      }
    } unless links.blank?

    links
  end

  def render_bottom_links
    w_class('cms_actions').new(:tree_node => presenter.website_node, 
      :options => {:buttons => %W{ new_button }, 
        :resource_types => %W{ link },:new_text => _(:new_bottom_link),
        :has_url => false, 
        :placeholder => 'bottom_links'
      }).render_to(self)
    ul(:class => 'links') {
      bottom_links.each_with_index { |e, i|
        li {rawtext '|'} unless i.eql?(0)
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e).render_to(self)
        }
      }
    } unless bottom_links.blank?
    bottom_links

  end
  
  def render_logo
    alt = _(@options[:alt]) rescue ''
    h1 = _(@options[:alt]) rescue false
    if h1
      h1(:id => 'logo') {
        a(:href => presenter.home){rawtext alt}
      }
    else
      a(:href => presenter.home){img(:id => 'logo', :src => img_path('logo.gif'), :alt => alt)}
    end
  end
  
  def render_copyright
    e = copyright
    # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
    updatable = 'up-' + presenter.website_node.id.to_s
    div(:id => updatable){

      if e.nil?
        w_class('cms_actions').new(:tree_node => presenter.website_node, 
          :options => {:buttons => %W{ new_button }, 
            :resource_types => %W{ copyright },
            :new_text => _(:new_copyright),
            :button_text => _(:add_copyright),
            :has_url => false
          }).render_to(self)

      else
        w_class('copyright').new(:tree_node => e).render_to(self)
      end
    }
  end
  
  def render_subscription
    e = subscription
    # Set the updatable div  - THIS DIV MUST BE AROUND THE CONTENT TO BE UPDATED.
    # Add 00 in order to differ from copyright
    updatable = 'up-00' + presenter.website_node.id.to_s
    div(:id => updatable){

      if e.nil?
        w_class('cms_actions').new(:tree_node => presenter.website_node, 
          :options => {:buttons => %W{ new_button }, 
            :resource_types => %W{ subscription },
            :new_text => _(:new_subscription),
            :button_text => _(:add_subscription),
            :has_url => false
          }).render_to(self)

      else
        w_class('subscription').new(:tree_node => e).render_to(self)
      end
    }
  end
  
  private
  
  def top_links_ext
    @top_links_ext ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'],
      :properties => {:external => true},
      :depth => 1,
      :placeholders => 'top_links_ext',
      :has_url => false
    )               
  end

  def top_links_int
    @top_links_int ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id,
      :resource_type_hrids => ['link'],
      :properties => {:external => false},
      :depth => 1,
      :placeholders => 'top_links_int',
      :has_url => false
    )
  end

  def languages
    @languages ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id,
      :resource_type_hrids => ['language'],
      :depth => 1,
      :placeholders => 'top_languages',
      :has_url => false
    )
  end

  def bottom_links
    @bottom_links ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['link'], 
      :depth => 1,
      :placeholders => 'bottom_links',
      :has_url => false
    )               
  end
  
  def copyright
    @copyright ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['copyright'], 
      :depth => 1,
      :has_url => false
    ) 
    @copyright.empty? ? nil : @copyright.first
  end
  
  def subscription
    @subscription ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id, 
      :resource_type_hrids => ['subscription'], 
      :depth => 1,
      :has_url => false
    ) 
    @subscription.empty? ? nil : @subscription.first
  end    
end
