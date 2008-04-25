module Widget

  class Base
    attr_reader :externals # This is a hash with all external params

    def initialize(args, template)
      @widget_name = args[:widget]
      @view_mode = args[:view_mode] || 'full'
      @externals = args[:locals]

      @template = template  

      # Add the widget view path to the template object
      custom_view_path = "#{RAILS_ROOT}/app/widgets"
      unless @template.view_paths.include?(custom_view_path)
        @template.prepend_view_path(custom_view_path)
      end
    end

    # Handles the rendering of the partial which is the widget's template code
    def render
      partial_path = @widget_name + '/' + @view_mode
      @template.render :partial => partial_path, :locals => {:widget => self}
    end

  end       

end