module BrawoCms
  module Fields
    class RepeaterField < BrawoCms::Field
      def initialize(definition)
        super
        @sub_fields = definition[:sub_fields] || []
      end

      def render_input_field(form, options, object)
        current_value = get_value(object) || []
        current_value = Array(current_value) unless current_value.is_a?(Array)
        
        # Filter out completely empty items (items with no values at all)
        # Don't filter based on required fields - those will be validated separately
        current_value = current_value.select do |item|
          next false unless item.is_a?(Hash)
          # Check if item has at least one non-empty value (any field, not just required ones)
          # Empty string, nil, empty array, empty hash are considered empty
          # But false and 0 are valid values
          item.values.any? do |v|
            case v
            when String
              v.present?
            when Array
              v.present?
            when Hash
              v.present?
            when NilClass
              false
            else
              true # Numbers, booleans, etc. are always considered present
            end
          end
        end
        
        helper = ActionController::Base.helpers
        helper.extend(BrawoCms::Admin::ApplicationHelper)
        helper.extend(BrawoCms::Admin::ReorderMenuHelper)
        
        # Get the form object name (e.g., "content" or "taxonomy") to prefix field names
        form_object_name = form.object_name.to_s
        
        helper.content_tag(:div, class: 'repeater-field', data: {
          controller: 'repeater',
          repeater_field_name_value: @name,
          action: 'sortable:sorted->repeater#reindex'
        }) do
          helper.content_tag(:div, class: 'repeater-items', id: "repeater_#{@name}_items", data: {
            controller: 'sortable',
            sortable_handle_value: '.repeater-drag-handle'
          }) do
            items_html = current_value.each_with_index.map do |item, index|
              render_repeater_row(form, item, index, helper, form_object_name)
            end
            template_html = helper.content_tag(:div, class: 'repeater-template', style: 'display: none;') do
              render_repeater_row(form, {}, 'INDEX', helper, form_object_name)
            end
            helper.safe_join(items_html) + template_html
          end +
          helper.content_tag(:button, I18n.t('brawo.fields.add_row'), type: 'button',
                            class: 'btn btn-sm btn-outline-primary mt-2',
                            data: { action: 'repeater#addRow' })
        end
      end

      def format_value(value)
        return empty_display_value unless value.present?
        
        value = Array(value) unless value.is_a?(Array)
        return empty_display_value if value.empty?
        
        helper = ActionController::Base.helpers
        
        # Display repeater items in a more detailed format
        helper.content_tag(:div, class: 'repeater-display') do
          items_html = value.each_with_index.map do |item, index|
            item_html = @sub_fields.map do |sub_field_def|
              sub_field = BrawoCms::FieldFactory.build(sub_field_def)
              field_value = item[sub_field.name.to_s] || item[sub_field.name.to_sym]
              
              if field_value.present?
                helper.content_tag(:div, class: 'mb-1') do
                  helper.content_tag(:strong, "#{sub_field.label}: ") +
                  sub_field.format_value(field_value)
                end
              end
            end.compact
            
            helper.content_tag(:div, class: 'card mb-2') do
              helper.content_tag(:div, class: 'card-body p-2') do
                helper.content_tag(:small, class: 'text-muted') do
                  I18n.t('brawo.fields.item', number: index + 1)
                end +
                helper.content_tag(:div, class: 'mt-1') do
                  helper.safe_join(item_html)
                end
              end
            end
          end
          
          helper.safe_join(items_html)
        end
      end

      private

      def render_repeater_row(form, item_data, index, helper, form_object_name)
        item_data ||= {}
        item_data = item_data.with_indifferent_access if item_data.respond_to?(:with_indifferent_access)
        
        helper.content_tag(:div, class: 'repeater-row card mb-2', data: { index: index }) do
          helper.content_tag(:div, class: 'card-body') do
            header = helper.content_tag(:div, class: 'repeater-row-header d-flex align-items-center gap-2 mb-2') do
              helper.content_tag(:span, '⋮⋮', class: 'repeater-drag-handle text-muted', title: I18n.t('brawo.page_builder.drag_to_reorder')) +
                helper.content_tag(:span, '', class: 'flex-grow-1') +
                helper.render_item_actions_dropdown(
                  move_action: 'repeater#moveRow',
                  remove_action: 'repeater#removeRow'
                )
            end

            fields_html = @sub_fields.map do |sub_field_def|
              sub_field = BrawoCms::FieldFactory.build(sub_field_def)
              # Prepend form object name to field name (e.g., "content[faq_items][0][question]")
              field_name = "#{form_object_name}[#{@name}][#{index}][#{sub_field.name}]"
              field_value = item_data[sub_field.name.to_s] || item_data[sub_field.name.to_sym]
              
              # Create a temporary object to hold the field value for rendering
              temp_object = OpenStruct.new(fields: { sub_field.name.to_s => field_value })
              
              helper.content_tag(:div, **helper.field_wrapper_attrs(sub_field_def)) do
                # Add required indicator to label
                label_text = sub_field.label
                label_text += ' <span class="text-danger">*</span>'.html_safe if sub_field.required
                
                if sub_field.type == :boolean || sub_field.type == :checkbox
                  # For checkboxes, wrap in form-check div
                  helper.content_tag(:div, class: 'form-check') do
                    input = render_nested_field_input(form, sub_field, field_name, temp_object, helper)
                    label = helper.label_tag(field_name, label_text, class: 'form-check-label', for: nil)
                    input + label
                  end
                else
                  label = helper.label_tag(field_name, label_text, class: 'form-label')
                  input = render_nested_field_input(form, sub_field, field_name, temp_object, helper)
                  label + input
                end
              end
            end
            
            header +
            helper.content_tag(:div, class: BrawoCms::Admin::FieldWrapperHelper::FIELD_ROW_CLASS) do
              helper.safe_join(fields_html)
            end
          end
        end
      end

      def render_nested_field_input(form, sub_field, field_name, temp_object, helper)
        field_value = temp_object.fields[sub_field.name.to_s]
        
        # Build base options with required attribute if needed
        base_options = {}
        base_options[:required] = true if sub_field.required && sub_field.type != :boolean && sub_field.type != :checkbox
        
        # Handle different field types and manually construct inputs
        case sub_field.type
        when :text, :textarea
          helper.text_area_tag(field_name, field_value, 
                              base_options.merge(class: 'form-control', rows: 5))
        when :string
          helper.text_field_tag(field_name, field_value, 
                               base_options.merge(class: 'form-control'))
        when :number, :integer
          helper.number_field_tag(field_name, field_value, 
                                 base_options.merge(class: 'form-control'))
        when :boolean, :checkbox
          # Checkboxes don't use required attribute (use aria-required for accessibility)
          options = { class: 'form-check-input' }
          options['aria-required'] = 'true' if sub_field.required
          helper.check_box_tag(field_name, '1', field_value, options)
        when :date
          helper.date_field_tag(field_name, field_value, base_options.merge(class: 'form-control'))
        when :datetime
          helper.datetime_local_field_tag(field_name, field_value, base_options.merge(class: 'form-control'))
        when :select
          options = sub_field.choices.map { |c| [c.is_a?(Array) ? c[0] : c, c.is_a?(Array) ? c[1] : c] }
          select_options = base_options.merge(class: 'form-select')
          select_options[:include_blank] = sub_field.required ? false : I18n.t('brawo.fields.select', label: sub_field.label)
          helper.select_tag(field_name, helper.options_for_select(options, field_value), select_options)
        else
          # Fallback to text field
          helper.text_field_tag(field_name, field_value, 
                               base_options.merge(class: 'form-control'))
        end
      end
    end
  end
end

