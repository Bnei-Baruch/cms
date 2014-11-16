class Mainsites::Widgets::GoogleAnalytics < WidgetManager::Base

  def render_full
    new_version = @presenter.site_settings[:google_analytics][:new_version] rescue false
    profile_key = @presenter.site_settings[:google_analytics][:profile_key] rescue nil

    if !new_version
      if ENV['RAILS_ENV'] != 'production' || @presenter.node.can_edit? || profile_key == nil
        javascript {
          rawtext 'var _gaq = _gaq || [];'
        }
        return
      end

      javascript {
        section_id = @presenter.main_section.id rescue '/unknown'
        special = ''
        section = case section_id
                  when nil # Homepage
                  when 3040
                    '/channel66'
                  when 477
                    '/music'
                  when 42
                    '/articles'
                  when 43
                    '/whatiskabbalah'
                  when 249
                    '/kabevents'
                  when 469
                    '/kabcolleges'
                  when 28316
                    '/kablessons'
                  when 44, 548
                    '/aboutus'
                  else
                    if tree_node.id == 32654 && tree_node.permalink == 'confirm_kab'
                      special = "/kabbalah/confirm_kab/newsletter/sign-up/completed"
                      nil
                    else
                      section_id.to_s
                    end
                  end
        rawtext <<-google1
          var google_analytics_new_version = false;
          var _gaq = _gaq || [];
          _gaq.push(['_setAccount', '#{profile_key}']);
          _gaq.push(['_setDomainName', 'kab.co.il']);
          _gaq.push(['_trackPreview']);
        google1

        if section
          rawtext <<-google2a
           _gaq.push(['_trackPageview', '#{section}' + window.location.pathname]);
          google2a
        end

        if special
          rawtext <<-google2b
           _gaq.push(['_trackPageview', '#{special}']);
          google2b
        end

        rawtext <<-google3
          setTimeout("_gaq.push(['_trackEvent', '15_seconds', 'read'])", 15000);
          (function(){
            var ga = document.createElement('script');
            ga.type = 'text/javascript';
            ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://' : 'http://') + 'stats.g.doubleclick.net/dc.js';
            var s = document.getElementsByTagName('script')[0];
            s.parentNode.insertBefore(ga, s);
          })();

        google3

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
                pageTracker = _gat._getTracker("#{profile_key}");
                pageTracker._trackPageview();
                setTimeout("pageTracker._trackEvent('NoBounce', 'NoBounce', 'Over 7 seconds')", 10000);

              } catch(err) {};
            });
          });
        google
      }
    end
  end
end
