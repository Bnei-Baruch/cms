class Mainsites::Widgets::Header < WidgetManager::Base

  def render_top_links
    site_config = $config_manager.site_settings(@presenter.website.hrid)
    if site_config[:single_logo][:use]
      a(:href => @presenter.home){
        img(:id => 'logo', :src => img_path("#{site_config[:site_name]}_logo.png"), :alt => site_config[:single_logo][:alt], :title => site_config[:single_logo][:alt])
        img(:id => 'star', :src => img_path("#{site_config[:site_name]}_star.png"), :alt => site_config[:single_logo][:alt], :title => site_config[:single_logo][:alt])
      }

      image_src = get_header_image
      alt = get_header_image_alt || _(:kabbalah_la_am)

      img(:id => 'logo-image', :src => image_src, :alt => alt, :title => alt) unless image_src.empty?
    end
    if site_config[:search_form]
      search_page = domain + '/' + presenter.controller.website.prefix + '/' + 'search'

      form(:action => search_page, :id => 'cse-search-box'){
        div(:class => 'search'){
          input :type => 'image', :src => img_path('search.gif'), :name => 'sa', :class => 'submit mobile-hidden'
          input :type => 'submit', :name => 'sa', :class => 'mobile-only', :value => 'חיפוש'
          input :type => 'hidden', :name => 'cx', :value => '009476949152162131478:o0ig8hkyjku'
          input :type => 'hidden', :name => 'ie', :value => 'UTF-8'
          input :type => 'hidden', :name => 'cof', :value => 'FORID:11;NB:1'
          input :type => 'text', :name => 'q', :size => '31', :class => 'text'
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

    w_class('cms_actions').new(:tree_node => presenter.website_node,
      :options => {:buttons => %W{ new_button },
        :resource_types => %W{ link }, :new_text => 'לינק חדש',
        :has_url => false,
        :placeholder => 'top_links'
      }).render_to(self)
    ul(:class => 'links') {
      top_links.each { |e|
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e, :view_mode => 'with_image').render_to(self)
        }
      }
    }

    top_links

  end

  def render_bottom_links
    w_class('cms_actions').new(:tree_node => presenter.website_node,
      :options => {:buttons => %W{ new_button },
        :resource_types => %W{ link }, :new_text => _(:new_bottom_link),
        :has_url => false,
        :placeholder => 'bottom_links'
      }).render_to(self)
    ul(:class => 'links') {
      bottom_links.each_with_index { |e, i|
        li {rawtext '|'} unless i.eql?(0)
        li(:id => sort_id(e)) {
          sort_handle
          w_class('link').new(:tree_node => e, :view_mode => 'new_window').render_to(self)
        }
      }
    } if bottom_links

    bottom_links

  end

  def render_logo
    div(:class => 'logo') do
      a(:href => presenter.home){img(:src => img_path('logo1.png'), :alt => _(:kabbalah_la_am), :title => _(:kabbalah_la_am), :style => 'margin-top:10px;width:180px;height:72px;float:right;')}
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
            :new_text =>   _(:new_copyright),
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

  def top_links
    @top_links ||=
      TreeNode.get_subtree(
      :parent => presenter.website_node.id,
      :resource_type_hrids => ['link'],
      :depth => 1,
      :placeholders => 'top_links',
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
