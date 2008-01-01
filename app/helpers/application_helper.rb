# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # This code was taken from active_record_helper.rb
  def rp_error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
      count = objects.inject(0) { |sum, obj|
        sum += params.inject(0) {|s, p|
          obj.errors.detect { |e|
            e.include?(p.to_s)
          }.blank? ? s : s + 1
        }
      }
      #      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
      count   = objects.inject(0) {|sum, object| sum + object.errors.count }
    end
    unless count.zero?
      html = {}
      [:id, :class].each do |key|
        if options.include?(key)
          value = options[key]
          html[key] = value unless value.blank?
        else
          html[key] = 'errorExplanation'
        end
      end
      options[:header_only] ||= false
      name = objects.first
      if name.respond_to?('property')
        options[:object_name] ||= name.property.name
      elsif name.respond_to?('resource_type')
        options[:object_name] ||= name.resource_type.name
      elsif name.respond_to?('name')
        options[:object_name] ||= name.name
      else
        options[:object_name] ||= ''
      end
      unless options.include?(:header_message)
				if options[:header_only]
					options[:header_message] = "Errors prohibited #{options[:object_name].to_s.gsub('_', ' ')} from being saved"
				else
					options[:header_message] = "#{options[:object_name].to_s.gsub('_', ' ')}"
				end
      end
      options[:message] ||= ''#There were problems with the following fields:' unless options.include?(:message)
      error_messages = objects.map {|object| object.errors.full_messages.map {|msg| content_tag(:li, msg) } }

      contents = ''
      contents << content_tag(options[:header_tag] || :h2, options[:header_message]) unless options[:header_message].blank?
      contents << content_tag(:p, options[:message]) unless options[:message].blank? or options[:header_only]
      contents << content_tag(:ul, error_messages) unless options[:header_only]

      content_tag(:div, contents, html)
    else
      ''
    end
  end

  # tell all of these methods to use my custom FormBuilder
  [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
    src = <<-end_src
      def cms_#{meth}(object_name, *args, &proc)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options.update(:builder => CMSFormBuilder)
        #{meth}(object_name, *(args << options), &proc)
      end
    end_src
    module_eval src, __FILE__, __LINE__
  end

  # the custom FormBuilder
  class CMSFormBuilder < ActionView::Helpers::FormBuilder
    [:password_field, :file_field, :text_area, :radio_button,
      :hidden_field, :text_field, :calendar_date_select].each do |meth|
      src = <<-end_src
      def #{meth}(method, options = {})
        if options.has_key?(:id)
          return super(method, options)
        end
        if object && @object_name.sub(/\\[\\]$/,"") and object.respond_to?(:to_param)
          options["id"] ||= "\#{sanitized_object_name}_\#{object.to_param}_\#{method}"
        end
        super(method, options)
      end
      end_src
      class_eval src, __FILE__, __LINE__
    end

    def check_box(method, options = {}, checked_value = "1", unchecked_value = "0")
      if options.has_key?(:id)
        return super(method, options, options, checked_value, unchecked_value)
      end
      if object && @object_name.sub(/\\[\\]$/,"") and object.respond_to?(:to_param)
        options["id"] ||= "#{sanitized_object_name}_#{object.to_param}_#{method}"
      end
      super(method, options, checked_value, unchecked_value)
    end
    
    def sanitized_object_name
      @object_name.sub(/\[\]$/,"").gsub(/[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    end
  end
  
  class ActionView::Helpers::InstanceTag
    def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
      options = options.stringify_keys
      options["type"]     = "checkbox"
      options["value"]    = checked_value
      if options.has_key?("checked")
        cv = options.delete "checked"
        checked = cv == true || cv == "checked"
      else
        checked = self.class.check_box_checked?(value(object), checked_value)
      end
      options["checked"] = "checked" if checked
      add_default_name_and_id(options)
      name = options.delete "name" # !!! That's the point + some JS
      tag("input", options) << tag("input", "name" => name, "type" => "hidden", "value" => options['disabled'] && checked ? checked_value : unchecked_value)
    end
  end

  # Handle to designage/move sortable elements
  def sort_handler(force = false)
    #    return unless logged_in?
    #    return if @is_homepage and (not force)
    '<img class="sort_handler" src="/images/arrow.gif" alt="" />'
  end
end
