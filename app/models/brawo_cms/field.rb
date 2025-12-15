module BrawoCms
  class Field
    attr_reader :name, :type, :label, :options, :help_text, :required, :choices

    def initialize(definition)
      @name = definition[:name].to_sym
      @type = (definition[:type] || :string).to_sym
      @label = definition[:label] || @name.to_s.humanize
      @options = definition[:options] || {}
      @help_text = definition[:help_text]
      @required = definition[:required] || false
      @choices = definition[:choices] || []
      
      # Type-specific options
      @taxonomy_type = definition[:taxonomy_type]
      @model_class = definition[:model_class]
    end

    # Get the raw value from a content/taxonomy object
    def get_value(object)
      object.get_field(@name)
    end

    # Format value for display
    def display_value(object)
      value = get_value(object)
      format_value(value)
    rescue => e
      Rails.logger.error("Error displaying field #{@name}: #{e.message}")
      value.present? ? value.to_s : '-'
    end

    # Format a raw value for display
    def format_value(value)
      return '-' unless value.present?
      value.to_s
    end

    # Render form input for this field
    def render_input(form, object)
      field_options = default_input_options.merge(@options)
      render_input_field(form, field_options, object)
    end

    protected

    def default_input_options
      { class: 'form-control' }
    end

    def render_input_field(form, options, object)
      form.text_field(@name, options)
    end

    def resolve_model_class(model_class_or_name)
      case model_class_or_name
      when Class
        model_class_or_name
      when String, Symbol
        model_class_or_name.to_s.classify.constantize
      else
        nil
      end
    rescue NameError
      nil
    end
  end
end

