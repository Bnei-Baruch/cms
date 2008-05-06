class Hebmain::Widgets::Article < WidgetManager::Base
    
  def render_full
    h3 get_title
    rawtext get_body 
  end

  private  

  def get_name
    resource.name rescue ''
  end
  
  def get_title
    resource.properties('title').value rescue ''
  end
  
  def get_body
    resource.properties('body').value rescue ''
  end

end
