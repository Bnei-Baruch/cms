class Hebmain::Widgets::GoogleAnalytics < WidgetManager::Base
  
  def render_full
  	return unless ENV['RAILS_ENV'] == 'production'

    # Delay loading until the last second
    javascript {
      rawtext <<-google
$(document).ready(function(){
   $.getScript('http://www.google-analytics.com/urchin.js', function(){
     _uacct = "UA-548326-62";
     urchinTracker();
   });
});
      google
    }
        
    # Future version of Google Analytics
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
