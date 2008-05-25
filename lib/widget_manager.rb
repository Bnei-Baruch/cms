module WidgetManager

  class Base < Erector::Widget
    include WidgetExtensions # additional helpers

    attr_accessor :presenter, :tree_node, :resource, :view_mode

    def initialize(*args, &block)
      super(*args, &block)
      @presenter = Thread.current[:presenter]
      @args_hash = args.detect{|arg|arg.is_a?(Hash)} || {}
      @tree_node = @args_hash[:tree_node] ? @args_hash[:tree_node] : presenter.node
      @view_mode = @args_hash[:view_mode] || 'full'
      @options = @args_hash[:options]
      @block = block
    end

    def render
      if @block # this will make the - WidgetManager::Base.new{text get_name} work. 
        instance_eval(&@block)
      else
        render_method = 'render_' + view_mode
        self.send(render_method, &block) if self.respond_to?(render_method)
      end
    end

    def method_missing(method_name, *args, &block)
      if tree_node && (method_name.to_s =~ /^get_(.+)/)
        my_args = args.detect{|arg|arg.is_a?(Hash)} || {}
        name = $1
        if name == 'name'
          metaclass.class_eval(
          "def #{method_name.to_s}(*args, &block)\n" <<
          "  resource.name rescue ''\n" <<
          "end",
          __FILE__,
          __LINE__ - 4
          )
          return resource.name rescue ''
        elsif rp = resource.properties(name)
          case rp.property_type
          when 'RpString', 'RpText', 'RpPlaintext'
            return rp.get_value rescue ''
          when 'RpNumber'
            return rp.get_value rescue nil
          when 'RpDate'
            if (rp && rp.get_value.is_a?(Date))
              return rp.get_value.strftime('%d.%m.%Y')
            else
              return ''
            end
          when 'RpFile'
            image_name = my_args[:image_name] || 'myself'
            return get_file_html_url(:attachment => rp.attachment, :image_name => image_name) rescue ''
          when 'RpBoolean'
            return rp.get_value rescue ''
          end
        else
          return ''
        end
      else
        super(method_name, *args, &block) # to initiate the framework's (Eractor) method missing
      end

    end

    def resource
      @resource ||= tree_node.resource rescue nil
    end



  end

  class Template < Base

    attr_reader :layout

    def initialize(*args, &block)
      super(*args, &block)
      layout_class = @args_hash[:layout_class] || nil
      @layout = layout_class.new(*args)

    end

    def render
      set_layout
      layout.render_to(doc)
    end

  end

  class Layout < Base
    def initialize(*args, &block)
      super(*args, &block)
    end

  end       

end