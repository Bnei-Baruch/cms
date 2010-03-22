class Hebmain::Widgets::AudioGallery < WidgetManager::Base

  def render_full
    header_initialized = false
    
    player_ini
    audio_gallery_admin
    make_sortable(:selector => '.audio_gallery', :axis => 'y') {
      ul(:class => 'audio_gallery'){
        audio_items.each_with_index { |audio_item, index|
          url = audio_item.resource.properties('url').get_value
          title = audio_item.resource.properties('title').get_value
          lyrics = audio_item.resource.properties('lyrics').get_value
          artist = audio_item.resource.properties('artist').get_value
          enable_download = audio_item.resource.properties('enable_download').get_value
          li(:id => sort_id(audio_item)){
            audio_admin audio_item
            sort_handle
            table{
              unless header_initialized
                header_initialized = true
                tr{
                  th(:class => 'number')  {rawtext '&nbsp;'}
                  th(:class => 'title')   {rawtext _(:song_title)}
                  th(:class => 'artist')  {rawtext _(:song_author)}
                  th(:class => 'download'){rawtext _(:song_download)}
                }
              end
              tr(:class => (index % 2) == 0 ? 'one' : 'two'){
                td(:class => 'number') {
                  rawtext "#{index+1}."
                }
                td(:class => 'title') {
                  rawtext title
                  br
                  div(:class => 'audioplayer_container', :id => "audioplayer_#{audio_item.object_id}"){
                    rawtext <<-message
                Audio clip: Adobe Flash Player (version 9 or above) is required to play this audio clip.
                Download the latest version <a href="http://www.adobe.com/shockwave/download/download.cgi?P1_Prod_Version=ShockwaveFlash&amp;promoid=BIOW" title="Download Adobe Flash Player">here</a>.
                You also need to have JavaScript enabled in your browser.
                    message
                  }
                  if lyrics != ''
                    a(:href => '#', :class =>'show_words'){
                      rawtext _(:show_words)
                    }
                  end
                  script{
                    rawtext <<-player
              AudioPlayer.embed("audioplayer_#{audio_item.object_id}", {
                soundFile: "#{url}",
                titles: " ",
                artists: " "
              });
                    player
                  }
                }
                td(:class => 'artist')  { rawtext artist }
                td(:class => 'download'){
                  if enable_download
                    a(:href => url) { rawtext _(:download)}
                  else
                    rawtext('&nbsp;')
                  end
                }
              }
              tr(:class => 'lyrics', :style => 'display:none;'){
                td
                td(:colspan => '3', :class => 'lyrics_data'){
                  rawtext lyrics
                }
              }
            }
          }
        }
      }

      audio_items
    }

  end

  private

  def audio_gallery_admin
    w_class('cms_actions').new( :tree_node => tree_node,
      :options => {:buttons => %W{ new_button edit_button delete_button },
        :resource_types => %W{ audio },
        :new_text => 'צור יחידת אודיו חדשה',
        :has_url => false
      }).render_to(self)
  end

  def audio_admin(audio_item)
    w_class('cms_actions').new( :tree_node => audio_item,
      :options => {:buttons => %W{ edit_button delete_button },
        :resource_types => %W{ audio },
        :has_url => false
      }).render_to(self)
  end
  
  def audio_items
    @audio_items ||= TreeNode.get_subtree(
      :parent => tree_node.id,
      :resource_type_hrids => ['audio'],
      :depth => 1,
      :has_url => false,
      :status => ['PUBLISHED', 'DRAFT']
    )
  end

  @@waudio_inited = false
  
  def player_ini
    return if @@waudio_inited

    @@waudio_inited = true
      
    script(:type => "text/javascript"){
      rawtext <<-ini_script
        AudioPlayer.setup("#{@presenter.domain}/javascripts/wpaudioplayer/player.swf", {
          width: 255,
          transparentpagebg:'yes',
          rtl: 'yes',
          leftbg: 'cccccc',
          lefticon: 'ffffff',
          voltrack: 'ffffff',
          volslider: '3a3a3a',
          rightbg: '83cce1',
          rightbghover: '33abce',
          righticon: 'ffffff',
          righticonhover: 'ffffff',
          loader: '83cce1',
          track: 'ffffff',
          tracker: 'c0f1ff',
          border: 'cfcfcf',
          text: '2d5d83'
        });

$(function() {
  $(".show_words").live('click', function(eventObject){
		$(this).removeClass("show_words").addClass("hide_words").text('הסתר מילים').parents('tr').addClass('changed_bg').next('.lyrics').show();
		eventObject.preventDefault();
		return false;
	});

  $(".hide_words").live('click', function(eventObject){
		$(this).removeClass("hide_words").addClass("show_words").text('הצג מילים').parents('tr').removeClass('changed_bg').next('.lyrics').hide();
		eventObject.preventDefault();
		return false;
	});

    $(".audio_gallery tr").not(".lyrics").not('.audios_tr').hover(
      function(){
        $(this).addClass('hover');
      },
      function(){
        $(this).removeClass('hover');
      }
    );
});
      ini_script
    }
  end
end

