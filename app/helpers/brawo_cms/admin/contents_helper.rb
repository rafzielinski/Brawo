module BrawoCms
  module Admin
    module ContentsHelper
      def status_badge_class(status)
        case status
        when 'published'
          'bg-success'
        when 'draft'
          'bg-warning'
        when 'archived'
          'bg-secondary'
        else
          'bg-info'
        end
      end

      def display_field_value(content, field)
        value = content.get_field(field[:name])
        
        case field[:type]
        when :date
          value.present? ? Date.parse(value).strftime("%B %d, %Y") : '-'
        when :datetime
          value.present? ? DateTime.parse(value).strftime("%B %d, %Y at %I:%M %p") : '-'
        when :boolean
          value ? '✓ Yes' : '✗ No'
        when :textarea
          simple_format(value)
        when :taxonomy
          display_taxonomy_value(value, field)
        when :reference
          display_reference_value(value, field)
        else
          value.present? ? value : '-'
        end
      rescue
        value.present? ? value : '-'
      end

      def display_taxonomy_value(value, field)
        return '-' unless value.present? && field[:taxonomy_type]
        
        taxonomy_config = BrawoCms.taxonomy_types[field[:taxonomy_type]]
        return value unless taxonomy_config
        
        taxonomy_class = taxonomy_config[:class]
        taxonomy_item = taxonomy_class.find_by(id: value)
        taxonomy_item ? taxonomy_item.name : '-'
      rescue
        value
      end

      def display_reference_value(value, field)
        return '-' unless value.present? && field[:model_class]
        
        model_class = resolve_model_class(field[:model_class])
        return '-' unless model_class
        
        ids = Array(value).compact
        return '-' if ids.empty?
        
        items = model_class.where(id: ids)
        items.map { |item| item.respond_to?(:title) ? item.title : item.respond_to?(:name) ? item.name : item.id }.join(', ')
      rescue
        value.is_a?(Array) ? value.join(', ') : value.to_s
      end

      def render_field_input(form, field, content)
        field_name = field[:name]
        field_type = field[:type] || :string
        field_options = field[:options] || {}
        
        case field_type
        when :string, :text
          form.text_field(field_name, class: 'form-control', **field_options)
        when :textarea
          form.text_area(field_name, class: 'form-control', rows: 5, **field_options)
        when :number, :integer
          form.number_field(field_name, class: 'form-control', **field_options)
        when :date
          form.date_field(field_name, class: 'form-control', **field_options)
        when :datetime
          form.datetime_field(field_name, class: 'form-control', **field_options)
        when :boolean, :checkbox
          form.check_box(field_name, class: 'form-check-input', **field_options)
        when :select
          form.select(field_name, field[:choices] || [], {}, class: 'form-select', **field_options)
        when :taxonomy
          render_taxonomy_select(form, field_name, field, field_options)
        when :reference
          render_reference_select(form, field_name, field, field_options)
        else
          form.text_field(field_name, class: 'form-control', **field_options)
        end
      end

      def render_taxonomy_select(form, field_name, field, field_options)
        taxonomy_type = field[:taxonomy_type]
        
        unless taxonomy_type
          return form.text_field(field_name, class: 'form-control', **field_options)
        end
        
        taxonomy_config = BrawoCms.taxonomy_types[taxonomy_type]
        unless taxonomy_config
          return form.text_field(field_name, class: 'form-control', **field_options)
        end
        
        taxonomy_class = taxonomy_config[:class]
        taxonomy_entries = taxonomy_class.all.order(:name)
        
        choices = taxonomy_entries.map { |entry| [entry.name, entry.id] }
        
        form.select(
          field_name, 
          choices, 
          { include_blank: field[:required] ? false : "Select #{field[:label] || field_name}" },
          class: 'form-select',
          **field_options
        )
      end

      def render_reference_select(form, field_name, field, field_options)
        model_class = resolve_model_class(field[:model_class])
        
        unless model_class
          return form.text_field(field_name, class: 'form-control', **field_options)
        end
        
        # Get all records from the model
        records = model_class.all.order(model_class.column_names.include?('title') ? :title : :name)
        
        # Build choices array
        choices = records.map do |record|
          label = record.respond_to?(:title) ? record.title : record.respond_to?(:name) ? record.name : record.id.to_s
          [label, record.id]
        end
        
        # Get current value (should be an array)
        current_value = Array(form.object.get_field(field_name)).compact.map(&:to_i)
        
        # Render multi-select
        form.select(
          "#{field_name}[]",
          choices,
          { selected: current_value },
          { multiple: true, class: 'form-select', size: [choices.length, 10].min, **field_options }
        )
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
end

