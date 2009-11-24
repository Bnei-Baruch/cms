class Hebmain::Widgets::GoogleAnalytics < WidgetManager::Base
  
  def render_full
    if ENV['RAILS_ENV'] != 'production' || @presenter.node.can_edit?
      javascript {
        rawtext <<-google
        function tracker() {}
        tracker.prototype._trackPageview = function(name){}
        var pageTracker = new tracker();
        google
      }
      return
    end

    # Delay loading until the last second
    # Old version of Google Analytics
#    javascript {
#      rawtext <<-google
#$(document).ready(function(){
#   $.getScript('http://www.google-analytics.com/urchin.js', function(){
#     _uacct = "UA-548326-62";
#     urchinTracker();
#   }, true);
#});
#      google
#    }
        
    javascript {
      rawtext <<-google
      var pageTracker = null;
        $(document).ready(function(){
          var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
          $.getScript(gaJsHost + 'google-analytics.com/ga.js', function(){
            try{
              pageTracker = _gat._getTracker("UA-548326-62");
              pageTracker._trackPageview();
            } catch(err) {};
          }, true);
        });
      google
}

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
