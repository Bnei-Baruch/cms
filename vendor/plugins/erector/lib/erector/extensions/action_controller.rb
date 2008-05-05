class ActionController::Base
  def render_widget(widget_class, assigns=@assigns)
    render :text => render_widget_to_string(widget_class, assigns)
  end

  def render_widget_to_string(widget_class, assigns = @assigns)
    add_variables_to_assigns
    @rendered_widget = widget_class.new(@template, assigns.merge(:params => params))
    @rendered_widget.to_s
  end
  
  def render_with_erector_widget(*options, &block)
    if options.first.is_a?(Hash) && widget = options.first.delete(:widget)
      render_widget widget, *options, &block
    else
      render_without_erector_widget *options, &block
    end
  end
  alias_method_chain :render, :erector_widget

  attr_reader :rendered_widget
end