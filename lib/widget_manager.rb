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
        name = $1
        if name == 'name'
          metaclass.class_eval(
          "def #{method_name.to_s}(*args, &block)\n" <<
          "  resource.name rescue ''\n" <<
          "end",
          __FILE__,
          __LINE__ - 4
          )
          return resource.name
        elsif rp = resource.properties(name)
          case rp.property_type
          when 'RpString', 'RpText', 'RpPlaintext'
            metaclass.class_eval(
            "def #{method_name.to_s}(*args, &block)\n" <<
            "  resource.properties('#{name}').value rescue ''\n" <<
            "end",
            __FILE__,
            __LINE__ - 4
            )
            return rp.value
          when 'RpNumber'
            metaclass.class_eval(
            "def #{method_name.to_s}(*args, &block)\n" <<
            "  resource.properties('#{name}').value.to_s rescue ''\n" <<
            "end",
            __FILE__,
            __LINE__ - 4
            )
            return rp.value.to_s
          when 'RpDate'
            metaclass.class_eval(
            "def #{method_name.to_s}(*args, &block)\n" <<
            "  rp = resource.properties('#{name}')\n" <<
            "  if (rp && rp.value.is_a?(Date))\n" <<
            "    rp.value.strftime('%d.%m.%Y')\n" <<
            "  else\n" <<
            "    ''\n" <<
            "  end\n" <<
            "end",
            __FILE__,
            __LINE__ - 4
            )
            if (rp && rp.value.is_a?(Date))
              return rp.value.strftime('%d.%m.%Y')
            else
              return ''
            end
          when 'RpFile'
            metaclass.class_eval(
            "def #{method_name.to_s}(*args, &block)\n" <<
            "  rp = resource.properties('#{name}')\n" <<
            "  get_file_html_url(:attachment => rp.attachment) if rp ''\n" <<
            "end",
            __FILE__,
            __LINE__ - 4
            )
            return get_file_html_url(:attachment => rp.attachment)
          end
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
      @layout = layout_class.new
      
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