class Hebmain::Layouts::Website < WidgetManager::Layout

  attr_accessor :ext_content, :ext_title, :ext_main_image, :ext_related_items

  def initialize(*args, &block)
    super
    @header = w_class('header').new()
    @static_tree = w_class('tree').new(:view_mode => 'static')
    @dynamic_tree = w_class('tree').new(:view_mode => 'dynamic', :display_hidden => true)
    @breadcrumbs = w_class('breadcrumbs').new()
    @titles = w_class('breadcrumbs').new(:view_mode => 'titles')
  end

  def render
    rawtext '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">'
    html("xmlns" => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", "lang" => "en") {
      head {
        meta "http-equiv" => "content-type", "content" => "text/html;charset=utf-8"
        meta "http-equiv" => "Content-language", "content" => "utf8"
        title ext_title
        css(get_css_external_url('reset-fonts-grids'))
        css(get_css_external_url('base-min'))
        css(get_css_external_url('../ext/resources/css/ext-all'))
        css(get_css_url('inner_page'))
        rawtext <<-ExtJS
          <script src="/javascripts/prototype.js" type="text/javascript"></script>
          <script src="/javascripts/scriptaculous.js?load=effects" type="text/javascript"></script>
          <script src="/javascripts/../ext/adapter/ext/ext-base.js" type="text/javascript"></script>
          <script src="/javascripts/../ext/ext-all-debug.js" type="text/javascript"></script>
          <script src="/javascripts/ext-helpers.js" type="text/javascript"></script>
        ExtJS
        #javascript(:src => "../javascripts/prototype.js")
        #javascript(:src => "../javascripts/scriptaculous.js?load=effects")
        #javascript(:src => "../ext/adapter/prototype/ext-prototype-adapter.js")
        #javascript(:src => "../ext/ext-all-debug.js")
        javascript() {
          # Start onReady
          rawtext <<-EXT_ONREADY
            Ext.onReady(function(){
              tree();
              tree_drop_zone("dz-1", "widget_id", "#{get_page_url(tree_node)}");
            });
          EXT_ONREADY
        }
      rawtext <<-css
        <style>
          .green{border: 1px solid green; margin:0 -2px; height:500px;}
          .red{border: 1px solid red; margin:0 -2px;height:250px;}
          .blue{border: 1px solid blue; margin:0 -2px;height:750px;}
          .purple{border: 1px solid purple; margin:0 -2px;height:120px;}
          .blue, .red, .green, .purple{text-align:center;}
        </style>
      css
      }
      body {
        # div(:id => 'doc2', :class => yui-t5){
        #   div(:id => 'hd', :class => 'purple'){
        #     text 'לוגו חיפוש וניווט סביבות'
        #   }
        #   div(:id='bd') {
        #     
        #   }
        # }
        rawtext <<-body
          <div id="doc2" class="yui-t5">
        		<div id="hd" class="purple"><%= yield :title %> לוגו חיפוש וניווט סביבות</div>
        		<div id="bd">
        			<div id="yui-main">
        				<div class="yui-b">
        					<div class="yui-gd"> 
        						<div class="yui-u first blue">קבלה אונליין</div>
        						<div class="yui-u">
        							<div class="red">אלמנט ראשי <%= yield %></div>
        							<div class="yui-gd">
        								<div class="yui-u green first">מקום לפרסום</div>
        								<div class="yui-u green">מקום לתכנים מומלצים</div>
        							</div>
        						</div>
        					</div> 
        				</div>
        			</div>
        			<div class="yui-b blue">מקום לתוכן למתחיל ותאור סביבות<%= yield :content_menu %></div>

        			<div id="ft" class="purple">פוטר של האתר</div>
        		</div>
        	</div>
        	
        body
      }
    }
  end           
end 
