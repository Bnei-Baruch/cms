class Hebmain::Widgets::GoogleAnalytics < WidgetManager::Base
  
  def render_full
    if ENV['RAILS_ENV'] != 'production' || @presenter.node.can_edit?
      javascript {
        rawtext 'function urchinTracker(){}'
      }
      return
    end

    # Delay loading until the last second
    javascript {
      rawtext <<-google
$(document).ready(function(){
   $.getScript('http://www.google-analytics.com/urchin.js', function(){
     _uacct = "UA-548326-62";
     urchinTracker();
   }, true);
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
