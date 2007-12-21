# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # This code was taken from active_record_helper.rb
  def rp_error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect {|object_name| instance_variable_get("@#{object_name}") }.compact
    end
    count   = objects.inject(0) {|sum, object| sum + object.errors.count }
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
        options[:object_name] ||= objects.first.property.name
      elsif name.respond_to?('resource_type')
        options[:object_name] ||= objects.first.resource_type.name
      else
        options[:object_name] ||= ''
      end
      unless options.include?(:header_message)
        options[:header_message] = "#{options[:header_only] ? 'Errors' : pluralize(count, 'error')} prohibited #{options[:object_name].to_s.gsub('_', ' ')} from being saved"
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
end
