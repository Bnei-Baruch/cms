class Ligdoltv::Templates::Website < WidgetManager::Template

  def set_layout
    layout.ext_meta_title = ext_meta_title
    layout.ext_meta_description = ext_meta_description
  end
  def ext_meta_title
    WidgetManager::Base.new do
      text get_title unless get_title.empty?
    end
  end
  def ext_meta_description
    WidgetManager::Base.new do
      text get_description unless get_description.empty?
    end
  end
end
