class Hebmain::Widgets::Newsletter < WidgetManager::Base
  
  def render_full
    rawtext <<-Google
<div class="newsletter">
  <h1>הרשמה לגיליון האלקטרוני</h1>

  <form class="inner" action="http://zip.netatlantic.com/subscribe/subscribe.tml" method="get">
    <p>
	<input type="text" id="form-search" name="email" onfocus="if(document.getElementById('form-search').value == 'הזן כתובת e-mail') { document.getElementById('form-search').value = ''; }" title="כתובת e-mail" value="הזן כתובת e-mail" />
	<input name="subscribe" class="button" value="הרשם" type="submit" title="הרשם" alt="הרשם" />
	<input type="hidden" name="Additional_" value="hebrew" />
	<input type="hidden" name="list" value="kabbalah" />
	<input type="hidden" name="demographics" value="Additional_" />
	<input type="hidden" name="confirm" value="none" />
    </p>
</form>
</div>

    Google
  end
end