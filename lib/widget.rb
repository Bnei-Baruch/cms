# args:
# :type - required - options: 'template', 'partial'
# :widget - required - the name of the widget
# :view_mode - optional - default: 'full' - the name of the view mode. 
#              the same widget could have different views
# :layout - optional - default: When template - the name of the widget in layouts folder
#                               When partial - false
# :locals - optional - the hash of args to pass to the widget. accessed through @widget.externals

# render widget as partial with layout (layout of partial will be put in the same folder where the partial is):
# render_widget :type => partial, :widget => 'content_page', :layout => 'large'
# render widget as template with layout
# render_widget :type => template, :widget => 'content_page', :vew_mode => 'small', :layout => 'large'
module Widget

  class Base
    attr_reader :externals # This is a hash with all external params
    attr_accessor :widget # to be able to access the widget from the view

    def initialize(args, presenter)
      @presenter = presenter
      @widget = self

      @widget_type = args[:type]
      @widget_name = args[:widget]
      @view_mode = args[:view_mode] || 'full'
      @widget_path =  @presenter.widget_path(args[:widget]) + '/' + @view_mode
      @externals = args[:locals]
      
      if args.has_key?(:layout) && args[:layout] == false
        @widget_layout = false
      elsif @widget_type == 'template'
        if args.has_key?(:layout)
          @widget_layout = @presenter.layout_path(args[:layout])
        else
          @widget_layout = @presenter.layout_path(args[:widget])
        end
      elsif @widget_type == 'partial'
        if args.has_key?(:layout)
          @widget_layout = @widget_path + '/' + args[:layout]
        else
          @widget_layout = false
        end
      else
        @widget_layout = false
      end
      
    end

    # Handles the rendering of the partial which is the widget's template code
    def render_me
      # @widget_path += '/' + @view_mode
      case @widget_type
      when 'template'
        {:template => @widget_path, :locals => {:widget => self}, :layout => @widget_layout}
      when 'partial'
        {:partial => @widget_path, :locals => {:widget => self}, :layout => @widget_layout}
      else
        nil
      end
    end

  end       

end