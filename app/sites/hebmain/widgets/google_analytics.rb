class Hebmain::Widgets::GoogleAnalytics < WidgetManager::Base
  
  def render_full
  	return unless ENV['RAILS_ENV'] == 'production'
  	
    rawtext <<-google
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script type="text/javascript">
_uacct = "UA-548326-62";
urchinTracker();
</script>        
        google
        
#         rawtext <<-Google
# 
# <script type="text/javascript">
# var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
# document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
# </script>
# <script type="text/javascript">
# var pageTracker = _gat._getTracker("UA-548326-62");
# pageTracker._initData();
# pageTracker._trackPageview();
# </script>
#         Google
   end
end