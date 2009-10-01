ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=nil, render_options = {})
    @__widget_class = widget_class
    if assigns
      @__widget_assigns = assigns
    else
      @__widget_assigns = {}
      variables = instance_variable_names
      variables -= protected_instance_variables
      variables.each do |name|
        @__widget_assigns[name.sub('@', "")] = instance_variable_get(name)
      end
    end
    response.template.send(:_evaluate_assigns_and_ivars)
    args = {:inline => "<% @__widget_class.new(self, @__widget_assigns, output_buffer).render %>"}
    args.merge!(render_options)
    render args
  end

  def render_with_erector_widget(*options, &block)
    if options.first.is_a?(Hash) && widget = options.first.delete(:widget)
      @my_options = options.first.delete(:render_options) || {}
      @assigns = {} if @assings.nil?
      @assigns.merge!(options.first)
      render_widget(widget, @assigns, @my_options, &block)
    else
      render_without_erector_widget(*options, &block)
    end
  end
  alias_method_chain :render, :erector_widget

end
