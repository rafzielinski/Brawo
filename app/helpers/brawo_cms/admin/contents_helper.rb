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
        when :repeater
          display_repeater_value(value, field)
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

      def display_repeater_value(value, field)
        return '-' unless value.present?
        
        rows = Array(value)
        return '-' if rows.empty?
        
        sub_fields = field[:sub_fields] || field[:fields] || []
        
        content_tag(:div, class: 'repeater-display') do
          rows.map.with_index do |row, index|
            content_tag(:div, class: 'repeater-row-display mb-3 p-3 border rounded') do
              content_tag(:strong, "Row #{index + 1}:", class: 'd-block mb-2') +
              content_tag(:dl, class: 'mb-0') do
                sub_fields.map do |sub_field|
                  sub_value = row.is_a?(Hash) ? (row[sub_field[:name].to_s] || row[sub_field[:name].to_sym]) : nil
                  
                  content_tag(:dt, sub_field[:label] || sub_field[:name].to_s.titleize, class: 'fw-bold') +
                  content_tag(:dd, class: 'mb-2') do
                    display_nested_field_value(sub_value, sub_field)
                  end
                end.join.html_safe
              end
            end
          end.join.html_safe
        end
      end

      def display_nested_field_value(value, field)
        return '-' unless value.present?
        
        case field[:type]
        when :date
          Date.parse(value).strftime("%B %d, %Y")
        when :datetime
          DateTime.parse(value).strftime("%B %d, %Y at %I:%M %p")
        when :boolean
          value ? '✓ Yes' : '✗ No'
        when :textarea
          simple_format(value)
        when :taxonomy
          display_taxonomy_value(value, field)
        when :reference
          display_reference_value(value, field)
        else
          value.to_s
        end
      rescue
        value.to_s
      end

      def render_field_input(form, field, content)
        # Handle both symbol and string keys
        field_name = field[:name] || field['name']
        field_type = field[:type] || field['type'] || :string
        field_options = field[:options] || field['options'] || {}
        
        # Normalize field_type to symbol for comparison
        field_type = field_type.to_sym if field_type.respond_to?(:to_sym)
        
        # Convert to string for case comparison
        field_type_str = field_type.to_s
        
        # Force output immediately - this should definitely show
        Rails.logger.error "*** ContentsHelper#render_field_input: name=#{field_name}, type_str=#{field_type_str} ***"
        puts "*** ContentsHelper#render_field_input: name=#{field_name}, type_str=#{field_type_str} ***"
        STDOUT.flush
        
        # Explicit check for repeater before case statement
        if field_type_str == 'repeater'
          Rails.logger.error "*** REPEATER DETECTED BEFORE CASE: field_type_str='#{field_type_str}' ***"
          return render_repeater_field(form, field_name, field, content)
        end
        
        result = case field_type_str
        when 'string', 'text'
          form.text_field(field_name, class: 'form-control', **field_options)
        when 'textarea'
          form.text_area(field_name, class: 'form-control', rows: 5, **field_options)
        when 'number', 'integer'
          form.number_field(field_name, class: 'form-control', **field_options)
        when 'date'
          form.date_field(field_name, class: 'form-control', **field_options)
        when 'datetime'
          form.datetime_field(field_name, class: 'form-control', **field_options)
        when 'boolean', 'checkbox'
          form.check_box(field_name, class: 'form-check-input', **field_options)
        when 'select'
          choices = field[:choices] || field['choices'] || []
          form.select(field_name, choices, {}, class: 'form-select', **field_options)
        when 'taxonomy'
          render_taxonomy_select(form, field_name, field, field_options)
        when 'reference'
          render_reference_select(form, field_name, field, field_options)
        when 'repeater'
          Rails.logger.error "*** CASE MATCHED REPEATER ***"
          render_repeater_field(form, field_name, field, content)
        else
          Rails.logger.error "*** CASE ELSE: field_type_str='#{field_type_str}', class=#{field_type_str.class}, inspect=#{field_type_str.inspect} ***"
          # Fallback to text field
          form.text_field(field_name, class: 'form-control', **field_options)
        end
        result
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

      def render_repeater_field(form, field_name, field, content)
        sub_fields = field[:sub_fields] || field['sub_fields'] || field[:fields] || field['fields'] || []
        current_value = Array(content.get_field(field_name))
        repeater_id = "repeater-#{field_name}"
        
        content_tag(:div, class: 'repeater-field', id: repeater_id, data: { field_name: field_name }) do
          content_tag(:div, class: 'repeater-rows') do
            rows_html = current_value.each_with_index.map do |row_data, index|
              render_repeater_row(form, field_name, sub_fields, row_data, index)
            end.join.html_safe
            
            rows_html + 
            content_tag(:div, class: 'repeater-empty-row', style: 'display: none;') do
              render_repeater_row(form, field_name, sub_fields, {}, '__INDEX__')
            end
          end +
          content_tag(:button, type: 'button', class: 'btn btn-sm btn-secondary mt-2 repeater-add-row', 
                      data: { field_name: field_name }) do
            'Add Row'
          end
        end
      end

      def render_repeater_row(form, field_name, sub_fields, row_data, index)
        row_id = index == '__INDEX__' ? '__INDEX__' : index
        content_tag(:div, class: 'repeater-row card mb-3', data: { index: row_id }) do
          content_tag(:div, class: 'card-body') do
            header = content_tag(:div, class: 'd-flex justify-content-between align-items-center mb-3') do
              content_tag(:h6, class: 'mb-0') do
                "Row #{row_id == '__INDEX__' ? '' : row_id + 1}"
              end +
              content_tag(:button, type: 'button', class: 'btn btn-sm btn-danger repeater-remove-row') do
                'Remove'
              end
            end
            
            fields_html = sub_fields.map do |sub_field|
              sub_field_name = sub_field[:name] || sub_field['name']
              sub_field_value = row_data.is_a?(Hash) ? row_data[sub_field_name.to_s] || row_data[sub_field_name.to_sym] : nil
              
              # Create a temporary object to hold the field value for rendering
              temp_object = OpenStruct.new(fields: { sub_field_name => sub_field_value })
              
              content_tag(:div, class: 'mb-3') do
                sub_field_label = sub_field[:label] || sub_field['label'] || sub_field_name.to_s.titleize
                sub_field_help = sub_field[:help_text] || sub_field['help_text']
                
                label = form.label("#{field_name}[#{row_id}][#{sub_field_name}]", 
                                   sub_field_label, 
                                   class: 'form-label')
                input = render_nested_field_input(form, "#{field_name}[#{row_id}][#{sub_field_name}]", 
                                                  sub_field, temp_object)
                help_text = if sub_field_help
                  content_tag(:small, sub_field_help, class: 'form-text text-muted')
                end
                
                label + input + (help_text || '')
              end
            end.join.html_safe
            
            header + fields_html
          end
        end
      end

      def render_nested_field_input(form, field_path, field, content_object)
        field_type = (field[:type] || field['type'] || :string).to_s
        field_options = field[:options] || field['options'] || {}
        field_name = field[:name] || field['name']
        current_value = content_object.respond_to?(:get_field) ? content_object.get_field(field_name) : content_object.fields[field_name.to_s]
        
        case field_type.to_s
        when 'string', 'text'
          form.text_field(field_path, value: current_value, class: 'form-control', **field_options)
        when 'textarea'
          form.text_area(field_path, current_value, class: 'form-control', rows: 5, **field_options)
        when 'number', 'integer'
          form.number_field(field_path, value: current_value, class: 'form-control', **field_options)
        when 'date'
          form.date_field(field_path, value: current_value, class: 'form-control', **field_options)
        when 'datetime'
          form.datetime_field(field_path, value: current_value, class: 'form-control', **field_options)
        when 'boolean', 'checkbox'
          form.check_box(field_path, { checked: current_value }, '1', '0', class: 'form-check-input', **field_options)
        when 'select'
          choices = field[:choices] || field['choices'] || []
          form.select(field_path, choices, { selected: current_value }, class: 'form-select', **field_options)
        when 'taxonomy'
          render_nested_taxonomy_select(form, field_path, field, field_options, current_value)
        when 'reference'
          render_nested_reference_select(form, field_path, field, field_options, current_value)
        else
          form.text_field(field_path, value: current_value, class: 'form-control', **field_options)
        end
      end

      def render_nested_taxonomy_select(form, field_path, field, field_options, current_value)
        taxonomy_type = field[:taxonomy_type]
        
        unless taxonomy_type
          return form.text_field(field_path, value: current_value, class: 'form-control', **field_options)
        end
        
        taxonomy_config = BrawoCms.taxonomy_types[taxonomy_type]
        unless taxonomy_config
          return form.text_field(field_path, value: current_value, class: 'form-control', **field_options)
        end
        
        taxonomy_class = taxonomy_config[:class]
        taxonomy_entries = taxonomy_class.all.order(:name)
        
        choices = taxonomy_entries.map { |entry| [entry.name, entry.id] }
        
        form.select(
          field_path, 
          choices, 
          { selected: current_value, include_blank: field[:required] ? false : "Select #{field[:label] || field[:name]}" },
          class: 'form-select',
          **field_options
        )
      end

      def render_nested_reference_select(form, field_path, field, field_options, current_value)
        model_class = resolve_model_class(field[:model_class])
        
        unless model_class
          return form.text_field(field_path, value: current_value, class: 'form-control', **field_options)
        end
        
        records = model_class.all.order(model_class.column_names.include?('title') ? :title : :name)
        
        choices = records.map do |record|
          label = record.respond_to?(:title) ? record.title : record.respond_to?(:name) ? record.name : record.id.to_s
          [label, record.id]
        end
        
        current_ids = Array(current_value).compact.map(&:to_i)
        
        # For nested repeater fields, field_path already includes the index, so we just append []
        form.select(
          "#{field_path}[]",
          choices,
          { selected: current_ids },
          { multiple: true, class: 'form-select', size: [choices.length, 10].min, **field_options }
        )
      end
    end
  end
end

