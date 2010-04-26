module WidgetManager

  class Base < Erector::Widget
    include WidgetExtensions # additional helpers

    attr_accessor :presenter, :tree_node, :resource, :view_mode

    def initialize(*args, &block)
      super(*args, &block)
      @presenter = Thread.current[:presenter]
      @args_hash = args.detect{|arg|arg.is_a?(Hash)} || {}
      @tree_node = @args_hash[:tree_node] || presenter.node
      @view_mode = @args_hash[:view_mode] || 'full'
      @options = @args_hash[:options]
      @block = block
      @skip_page_map = true if self.respond_to?(:skip_page_map)
    end

    def self.skip_page_map
      instance_eval('attr_accessor :skip_page_map')
    end

    def render
      if @block # this will make the - WidgetManager::Base.new{text get_name} work. 
        instance_eval(&@block)
      else
        render_method = 'render_' + view_mode
        if self.respond_to?(render_method)
          skip = self.respond_to?(:skip_page_map) && @skip_page_map
          Thread.current[:skip_page_map] = true if skip
          begin
            result = self.send(render_method, &block)
          rescue Exception => ex
             raise ex unless Rails.env == 'production'
          end

          Thread.current[:skip_page_map] = false if skip
          result
        end
      end
    end

    def method_missing(method_name, *args, &block)
      if tree_node && (method_name.to_s =~ /^get_(.+)/)
        name = $1
        if name == 'name'
          self.class.class_eval{
            def get_name(*args, &block)
              resource.name rescue ''
            end
          }
          return resource.name rescue ''
        elsif rp = resource.properties(name)
          rp = rp[0] if rp.kind_of?(Array)
          case rp.property_type
          when 'RpString', 'RpText', 'RpPlaintext'
            self.class.class_eval(
              "def #{method_name.to_s}(*args, &block)\n" <<
                "  resource.properties('#{name}').get_value rescue ''\n" <<
                "end",
              __FILE__,
              __LINE__ - 4
            )
            return rp.get_value rescue ''
          when 'RpNumber'
            self.class.class_eval(
              "def #{method_name.to_s}(*args, &block)\n" <<
                "  resource.properties('#{name}').get_value rescue nil\n" <<
                "end",
              __FILE__,
              __LINE__ - 4
            )
            return rp.get_value rescue nil
          when 'RpDate'
            self.class.class_eval(
              "def #{method_name.to_s}(*args, &block)\n" <<
                "  rp = resource.properties('#{name}')\n" <<
                "  rp = rp[0] if rp.kind_of?(Array)\n" <<
                "  if (rp && rp.get_value.is_a?(Date))\n" <<
                "    return rp.get_value.strftime('%d.%m.%Y')\n" <<
                "  else\n" <<
                "    return ''\n" <<
                "  end\n" <<
                "end",
              __FILE__,
              __LINE__ - 4
            )
            if (rp && rp.get_value.is_a?(Date))
              return rp.get_value.strftime('%d.%m.%Y')
            else
              return ''
            end
          when 'RpFile'
            self.class.class_eval(
              "def #{method_name.to_s}(*args, &block);" <<
                "  rp = resource.properties('#{name}');" <<
                "  my_args = args.detect{|arg|arg.is_a?(Hash)} || {};" <<
                "  image_name = my_args[:image_name] || 'myself';" <<
                "  dimensions = my_args[:with_dimensions];" <<
                "  path = get_file_html_url(:attachment =>  Attachment.get_short_attachment(rp.id), :image_name => image_name) rescue ''\n" <<
                "  return path unless dimensions\n" <<
                "  dims = Attachment.get_dims_attachment(rp.id, image_name, path)\n" <<
                "  return path, dims\n" <<
                "end",
              __FILE__,
              __LINE__ - 4
            )
            my_args = args.detect{|arg|arg.is_a?(Hash)} || {}
            image_name = my_args[:image_name] || 'myself'
            dimensions = my_args[:with_dimensions]
            path = get_file_html_url(:attachment =>  Attachment.get_short_attachment(rp.id), :image_name => image_name) rescue ''
            return path unless dimensions
            dims = Attachment.get_dims_attachment(rp.id, image_name, path)
            return path, dims
          when 'RpBoolean'
            self.class.class_eval(
              "def #{method_name.to_s}(*args, &block)\n" <<
                "  prop = resource.properties('#{name}');" <<
                "  prop = prop[0] if (prop.is_a?(Array));" <<
                "  prop.get_value rescue ''\n" <<
                "end",
              __FILE__,
              __LINE__ - 4
            )
            return rp.get_value rescue ''
          end
        else
          return ''
        end
      else
        super(method_name, *args, &block) # to initiate the framework's (Erector) method missing
      end

    end

    def resource
      #@resource ||= tree_node.resource rescue nil
      # @resource ||= Resource.find(:first, :conditions => [ "id = ?", tree_node.resource_id] , :include => [ :resource_properties ]) rescue nil
      @resource ||= Resource.find(:first, :conditions => [ "id = ?", tree_node.resource_id]) rescue nil #**RAMI**
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
      layout.render_to(self)
    end

  end

  class Layout < Base
    def initialize(*args, &block)
      super(*args, &block)
    end

    def display(view)
      view.render_to(self)
    end
  end       

end

