class Hebmain::Widgets::GoogleAnalytics < WidgetManager::Base
  
  def render_full
    new_version = @presenter.site_settings[:google_analytics][:new_version] rescue false
    profile_key = @presenter.site_settings[:google_analytics][:profile_key] rescue nil

    if !new_version
      if ENV['RAILS_ENV'] != 'production' || @presenter.node.can_edit? || profile_key == nil
        javascript {
          rawtext 'function urchinTracker(){}'
        }
        return
      end
      # Delay loading until the last second
      javascript {
        rawtext <<-google
        var google_analytics_new_version = false
        $(document).ready(function(){
          $.getScript('http://www.google-analytics.com/urchin.js', function(){
           _uacct = "UA-548326-62";
           urchinTracker();
          });
        });
        google
      }
    else  
      if ENV['RAILS_ENV'] != 'production' || @presenter.node.can_edit? || profile_key == nil
        javascript {
          rawtext <<-google
          function tracker() {}
          tracker.prototype._trackPageview = function(name){}
          var pageTracker = new tracker();
          google
        }
        return
      end
      javascript {
        rawtext <<-google
        var google_analytics_new_version = true
        var pageTracker = null;
          $(document).ready(function(){
            var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
            $.getScript(gaJsHost + 'google-analytics.com/ga.js', function(){
              try{
                pageTracker = _gat._getTracker("UA-548326-62");
                pageTracker._trackPageview();
                setTimeout('pageTracker._trackEvent(\'NoBounce\', \'NoBounce\', \'Over 7 seconds\')', 10000);

              } catch(err) {};
            });
          });
        google
      }
    end
  end
end
