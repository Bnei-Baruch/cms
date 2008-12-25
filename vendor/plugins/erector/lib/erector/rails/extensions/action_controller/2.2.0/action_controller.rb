ActionController::Base.class_eval do
  def render_widget(widget_class, assigns=nil)
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
    render :inline => "<% @__widget_class.new(self, @__widget_assigns, output_buffer).render %>"
  end

  def render_with_erector_widget(*options, &block)
    if options.first.is_a?(Hash) && widget = options.first.delete(:widget)
      @assigns = {} if @assings.nil?
      @assigns.merge!(options.first)
      render_cached_widget(widget, @assigns, &block)
    else
      render_without_erector_widget(*options, &block)
    end
  end
  alias_method_chain :render, :erector_widget

  def render_cached_widget(widget, assigns, &block)
    if AuthenticationModel.current_user_is_anonymous?
      # TRUE in case a request is made via XHR(Ajax) or in non-development mode
      # To cache even in development mode (but only non-Ajax) change
      #       Rails.env == 'development'
      # to
      #       Rails.env != 'development'
      # Do not forget also to uncomment correspondent lines in development.rb
      miss_cache = assigns[:options][:force] rescue Rails.env == 'development'
      if miss_cache
        render_widget(widget, assigns, &block)
      else
        if result = Rails.cache.fetch(this_cache_key)
          render :text => result
        else
          Rails.cache.write(this_cache_key,
		render_widget(widget, assigns, &block))
        end
      end
    else
      # Authenticated user
      render_widget(widget, assigns, &block)
    end
  end


  private
  def this_cache_key
    @presenter.node.cache_key
  end

end
