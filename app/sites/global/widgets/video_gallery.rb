class Global::Widgets::VideoGallery < WidgetManager::Base
  
  def render_homepage
    video_admin
    id = tree_node.object_id

    if @presenter.is_homepage?
      link = "/homepage/video"
    else
      link = "/homepage/video/#{@presenter.node.permalink}"
    end

    div(:class => 'player', :id => "id-#{id}") {
      image = get_image
      if image && !image.empty?
        image = "{url:'#{image}',autoPlay:true},"
      else
        image = ''
      end
      videos = video_items.collect { |video_item|
        w_class('video').new(:tree_node => video_item, :view_mode => 'homepage_one_video').render_to(self)
      }.join(',')

      div(:id => "flashplayer-#{id}", :style => 'height:195px;width:226px;'){}
      javascript {
        rawtext <<-Embedjs
          $(document).ready(function() {
               flowplayer('flashplayer-#{id}',{src: '/flowplayer/flowplayer.commercial-3.2.5.swf', wmode: 'transparent'},{
                  key:'#\@f0b2be6a10fb2019139',
                  clip:{
                    scaling: 'scale',
                    autoPlay: false,

                    // track start event for this clip
                    onStart: function(clip) {
                        ga('#{link}/start', clip.url);
                        _tracker._trackEvent("Videos", "Start", clip.url);
                    },

                    // track pause event for this clip. time (in seconds) is also tracked
                    onPause: function(clip) {
                        ga('#{link}/pause', clip.url, parseInt(this.getTime()));
                        _tracker._trackEvent("Videos", "Pause", clip.url, parseInt(this.getTime()));
                    },

                    // track stop event for this clip. time is also tracked
                    onStop: function(clip) {
                        ga('#{link}/stop', clip.url, parseInt(this.getTime()));
                        _tracker._trackEvent("Videos", "Stop", clip.url, parseInt(this.getTime()));
                    },

                    // track finish event for this clip
                    onFinish: function(clip) {
                        ga('#{link}/finish', clip.url);
                        _tracker._trackEvent("Videos", "Finish", clip.url);
                    }
                  },
                  #{'play: null,' if tree_node.can_edit?}
                  playlist:[
                    #{image}
                    #{videos}
                  ],
                  // show stop button so we can see stop events too
                  plugins: {
                      controls: {
                          url: '/flowplayer/flowplayer.controls-3.2.3.swf',
                          time: false
                      }
                  }
               });
        });
        Embedjs
      }

      #      TODO: to restore option to play more than one video
      #      http://static.flowplayer.org/forum/4/23865
      #      if video_items.size > 1 || !AuthenticationModel.current_user_is_anonymous?
      #        div(:id => "playlist-#{id}", :class => 'playlist'){
      #          ol{
      #            video_items.each { |video_item|
      #              li {w_class('video').new(:tree_node => video_item, :view_mode => 'homepage_gallery').render_to(self)}
      #            }
      #          }
      #        }
      #      end
      a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url
    }
  end
  
  def render_full
    video_admin
    id = tree_node.object_id
    image = get_image(:image_name => 'myself')
    title = get_title
    first_with_image = video_items.detect { |item| item.resource.properties('image') } unless image
    image ||= get_file_html_url(:attachment => first_with_image.resource.properties('image').attachment, :image_name => 'myself') if first_with_image
    title ||= first_with_image.resource.properties('title').get_value if first_with_image

    div(:class => 'inner-player', :id => "id-#{id}") {
      div(:class => 'play-title') {
        rawtext title if title
      }

      div(:style => "height:403px;width:504px;cursor:pointer;", :id => "flashplayer-#{id}"){
        img(:src => image) if image && !image.empty?
      }

      div(:class => 'play-serv'){}
      div(:id => "playlist-#{id}", :class => 'playlist'){
        ul{
          video_items.each { |video_item|
            li {w_class('video').new(:tree_node => video_item, :view_mode => 'video_list').render_to(self)}
          }
        }
      }
      a get_url_text, :href => get_url, :title => 'link', :class => 'more' if get_url != ""
    }
    p(:class => "play-list-button"){
      a{
        span _(:play)
        b {rawtext '&nbsp;'}
      }
    }
  end

  private

  def video_admin
    w_class('cms_actions').new( :tree_node => tree_node, 
      :options => {:buttons => %W{ new_button edit_button delete_button }, 
        :resource_types => %W{ video },
        :new_text => _(:create_new_video_item),
        :has_url => false
      }).render_to(self)
  end
  
  def video_items
    @video_items ||= TreeNode.get_subtree(
      :parent => tree_node.id, 
      :resource_type_hrids => ['video'], 
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )               
  end
  
end

