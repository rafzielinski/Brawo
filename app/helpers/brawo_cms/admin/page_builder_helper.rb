module BrawoCms
  module Admin
    module PageBuilderHelper
      def render_page_builder(form, field_name, blocks)
        blocks = Array(blocks)

        content_tag(:div, class: 'page-builder', data: {
          controller: 'page-builder',
          page_builder_field_name_value: field_name,
          page_builder_form_prefix_value: form.object_name,
          action: 'sortable:sorted->page-builder#reindex keydown@window->page-builder#closePickerOnEscape'
        }) do
          safe_join([
            content_tag(:div, class: 'page-builder-layout') do
              render_canvas_area(form, field_name, blocks) + render_outline_panel(blocks)
            end,
            render_block_picker,
            render_templates(form, field_name)
          ])
        end
      end

      def render_canvas_area(form, field_name, blocks)
        content_tag(:div, class: 'page-builder-workspace') do
          safe_join([
            render_add_block_button('top', 0),
            content_tag(:div, class: 'page-builder-canvas', data: {
              controller: 'sortable',
              sortable_handle_value: '.drag-handle',
              page_builder_target: 'canvas'
            }) do
              safe_join(build_canvas_children(form, field_name, blocks))
            end,
            render_add_block_button('bottom', blocks.size),
            content_tag(:p, 'No blocks yet. Click “Add block” to get started.',
              class: "text-muted page-builder-empty text-center py-4#{' is-hidden' if blocks.any?}")
          ])
        end
      end

      def build_canvas_children(form, field_name, blocks)
        children = [render_insert_zone(0)]
        blocks.each_with_index do |block, index|
          children << render_block_row(form, field_name, block, index)
          children << render_insert_zone(index + 1)
        end
        children
      end

      def render_add_block_button(position, insert_at)
        content_tag(:div, class: "page-builder-add-bar page-builder-add-bar--#{position}") do
          button_tag(type: 'button', class: 'btn btn-outline-primary btn-sm',
            data: { action: 'page-builder#openPicker', insert_position: insert_at }) do
            '+ Add block'
          end
        end
      end

      def render_insert_zone(position)
        content_tag(:div, class: 'block-insert-zone', data: { insert_position: position }) do
          content_tag(:button, '+', type: 'button', class: 'block-insert-zone-btn',
            title: 'Insert block here',
            data: { action: 'page-builder#openPicker', insert_position: position })
        end
      end

      def render_block_picker
        content_tag(:div, class: 'page-builder-picker offcanvas offcanvas-end', tabindex: '-1',
          data: { page_builder_target: 'picker' }) do
          content_tag(:div, class: 'offcanvas-header') do
            content_tag(:h5, 'Choose block type', class: 'offcanvas-title') +
              button_tag(type: 'button', class: 'btn-close',
                data: { action: 'page-builder#closePicker' }, aria: { label: 'Close' })
          end +
            content_tag(:div, class: 'offcanvas-body') do
              content_tag(:div, class: 'd-grid gap-2') do
                safe_join(BrawoCms.block_types.map do |type_name, config|
                  button_tag(config[:label], type: 'button', class: 'btn btn-outline-secondary text-start',
                    data: { action: 'page-builder#pickBlockType', block_type: type_name })
                end)
              end
            end
        end
      end

      def render_outline_panel(blocks)
        content_tag(:aside, class: 'page-builder-outline', data: { page_builder_target: 'outlinePanel' }) do
          content_tag(:div, class: 'page-builder-outline-header') do
            content_tag(:h6, 'Structure', class: 'mb-0') +
              button_tag(type: 'button', class: 'btn btn-sm btn-link page-builder-outline-close',
                data: { action: 'page-builder#toggleOutline' }, aria: { label: 'Close panel' }) { '×' }
          end +
            content_tag(:ul, class: 'page-builder-outline-list list-unstyled mb-0',
              data: { controller: 'sortable', sortable_handle_value: '.outline-drag-handle',
                action: 'sortable:sorted->page-builder#reindexFromOutline',
                page_builder_target: 'outline' }) do
              safe_join(blocks.each_with_index.map do |block, index|
                render_outline_item(block, index)
              end)
            end
        end +
          button_tag(type: 'button', class: 'page-builder-outline-toggle',
            data: { action: 'page-builder#toggleOutline' },
            title: 'Toggle structure panel') { 'Structure' }
      end

      def render_outline_item(block, index)
        block = block.with_indifferent_access
        block_type = block[:type]
        type_config = BrawoCms.block_type(block_type)
        label = type_config ? type_config[:label] : block_type.to_s.humanize
        summary = block_summary(block_type, block[:data] || {})

        content_tag(:li, class: 'page-builder-outline-item', data: {
          block_index: index,
          action: 'click->page-builder#focusBlock'
        }) do
          content_tag(:span, '⋮⋮', class: 'outline-drag-handle', title: 'Drag to reorder') +
            content_tag(:span, class: 'outline-item-label') do
              content_tag(:strong, label) + tag.br + content_tag(:span, summary, class: 'text-muted small')
            end
        end
      end

      def render_templates(form, field_name)
        content_tag(:div, class: 'page-builder-templates') do
          safe_join(BrawoCms.block_types.map do |type_name, config|
            render_block_template(form, field_name, type_name, config)
          end)
        end
      end

      def render_block_row(form, field_name, block, index)
        block = block.with_indifferent_access if block.respond_to?(:with_indifferent_access)
        block_type = block[:type] || block['type']
        block_data = block[:data] || block['data'] || {}
        type_config = BrawoCms.block_type(block_type)
        return '' unless type_config

        content_tag(:div, class: 'page-builder-block card', data: {
          block_type: block_type,
          block_index: index
        }) do
          content_tag(:div, class: 'card-body') do
            block_header(block_type, type_config[:label], block_data, index) +
              hidden_field_tag("#{form.object_name}[#{field_name}][#{index}][type]", block_type) +
              content_tag(:div, class: 'block-fields mt-3') do
                render_block_data_fields(form, field_name, index, type_config[:fields], block_data)
              end
          end
        end
      end

      def render_block_template(form, field_name, type_name, config)
        content_tag(:div, class: 'page-builder-template', data: { block_type: type_name }) do
          content_tag(:div, class: 'page-builder-block card', data: { block_type: type_name, block_index: 'INDEX' }) do
            content_tag(:div, class: 'card-body') do
              block_header(type_name, config[:label], {}, 'INDEX') +
                hidden_field_tag("#{form.object_name}[#{field_name}][INDEX][type]", type_name, disabled: true) +
                content_tag(:div, class: 'block-fields mt-3') do
                  render_block_data_fields(form, field_name, 'INDEX', config[:fields], {}, disabled: true)
                end
            end
          end
        end
      end

      def block_header(block_type, label, data, index)
        summary = block_summary(block_type, data)
        content_tag(:div, class: 'page-builder-block-header d-flex align-items-center gap-2') do
          content_tag(:span, '⋮⋮', class: 'drag-handle text-muted', title: 'Drag to reorder') +
            content_tag(:span, label, class: 'badge bg-primary') +
            content_tag(:span, summary, class: 'text-muted small flex-grow-1 text-truncate') +
            render_block_menu(index)
        end
      end

      def render_block_menu(index)
        content_tag(:div, class: 'dropdown page-builder-block-menu') do
          button_tag('⋯', type: 'button', class: 'btn btn-sm btn-light',
            data: { bs_toggle: 'dropdown' }, aria: { expanded: 'false' }) +
            content_tag(:ul, class: 'dropdown-menu dropdown-menu-end') do
              safe_join([
                content_tag(:li) do
                  button_tag('Insert above', type: 'button', class: 'dropdown-item',
                    data: { action: 'page-builder#openPickerRelative', insert_offset: 0 })
                end,
                content_tag(:li) do
                  button_tag('Insert below', type: 'button', class: 'dropdown-item',
                    data: { action: 'page-builder#openPickerRelative', insert_offset: 1 })
                end,
                content_tag(:li) { tag.hr(class: 'dropdown-divider') },
                content_tag(:li) do
                  button_tag('Remove', type: 'button', class: 'dropdown-item text-danger',
                    data: { action: 'page-builder#removeBlock' })
                end
              ])
            end
        end
      end

      def block_summary(block_type, data)
        data = data.with_indifferent_access if data.respond_to?(:with_indifferent_access)
        case block_type.to_sym
        when :heading
          data[:text].presence || '(empty heading)'
        when :text
          data[:body].to_s.truncate(60).presence || '(empty text)'
        when :faq
          count = Array(data[:items]).size
          "#{data[:section_title].presence || 'FAQ'} (#{count} items)"
        else
          block_type.to_s.humanize
        end
      end

      def render_block_data_fields(form, field_name, block_index, field_defs, data, disabled: false)
        data = data.with_indifferent_access if data.respond_to?(:with_indifferent_access)
        prefix = "#{form.object_name}[#{field_name}][#{block_index}][data]"

        content_tag(:div, class: 'row') do
          safe_join(field_defs.map do |field_def|
            sub_field = BrawoCms::FieldFactory.build(field_def)
            field_key = sub_field.name.to_s
            field_value = data[field_key] || data[field_key.to_sym]
            input_name = "#{prefix}[#{field_key}]"

            content_tag(:div, class: field_column_class(field_def)) do
              render_block_field_input(sub_field, field_def, input_name, field_value, prefix, disabled: disabled)
            end
          end)
        end
      end

      def field_column_class(field_def)
        field_def[:type] == :repeater ? 'col-12 mb-2' : 'col-md-6 mb-2'
      end

      def render_block_field_input(sub_field, field_def, input_name, field_value, prefix, disabled: false)
        label_text = sub_field.label
        label_text += ' <span class="text-danger">*</span>'.html_safe if sub_field.required

        if field_def[:type] == :repeater
          render_block_repeater(field_def, input_name, field_value, disabled: disabled)
        elsif field_def[:type] == :boolean || field_def[:type] == :checkbox
          content_tag(:div, class: 'form-check') do
            check_box_tag(input_name, '1', field_value, class: 'form-check-input', disabled: disabled) +
              label_tag(input_name, label_text.html_safe, class: 'form-check-label')
          end
        else
          label_tag(input_name, label_text.html_safe, class: 'form-label') +
            render_scalar_block_input(sub_field, field_def, input_name, field_value, disabled: disabled)
        end
      end

      def render_scalar_block_input(sub_field, field_def, input_name, field_value, disabled: false)
        options = { class: 'form-control', disabled: disabled }
        options[:required] = true if sub_field.required

        case field_def[:type]
        when :text, :textarea
          text_area_tag(input_name, field_value, options.merge(rows: 5))
        when :number, :integer
          number_field_tag(input_name, field_value, options)
        when :date
          date_field_tag(input_name, field_value, options)
        when :datetime
          datetime_local_field_tag(input_name, field_value, options)
        when :select
          choices = sub_field.choices.map { |c| c.is_a?(Array) ? c : [c, c] }
          select_tag(input_name, options_for_select(choices, field_value),
            options.merge(class: 'form-select'))
        else
          text_field_tag(input_name, field_value, options)
        end
      end

      def render_block_repeater(field_def, input_name, field_value, disabled: false)
        field_value = Array(field_value)
        repeater_name = field_def[:name]
        base_name = input_name

        content_tag(:div, class: 'repeater-field', data: {
          controller: 'repeater',
          repeater_field_name_value: repeater_name
        }) do
          content_tag(:label, field_def[:label] || repeater_name.to_s.humanize, class: 'form-label') +
            content_tag(:div, class: 'repeater-items') do
              rows = field_value.each_with_index.map do |item, idx|
                render_block_repeater_row(field_def, base_name, item, idx, disabled: disabled)
              end
              template = content_tag(:div, class: 'repeater-template') do
                render_block_repeater_row(field_def, base_name, {}, 'INDEX', disabled: disabled)
              end
              safe_join(rows) + template
            end +
            button_tag('+ Add Row', type: 'button', class: 'btn btn-sm btn-outline-primary mt-2',
              disabled: disabled, data: { action: 'repeater#addRow' })
        end
      end

      def render_block_repeater_row(field_def, base_name, item_data, index, disabled: false)
        item_data = item_data.with_indifferent_access if item_data.respond_to?(:with_indifferent_access)
        sub_fields = field_def[:sub_fields] || []

        content_tag(:div, class: 'repeater-row card mb-2', data: { index: index }) do
          content_tag(:div, class: 'card-body') do
            fields_html = sub_fields.map do |sub_field_def|
              sub_field = BrawoCms::FieldFactory.build(sub_field_def)
              sub_name = "#{base_name}[#{index}][#{sub_field.name}]"
              sub_value = item_data[sub_field.name.to_s] || item_data[sub_field.name.to_sym]

              content_tag(:div, class: 'col-md-6 mb-2') do
                render_block_field_input(sub_field, sub_field_def, sub_name, sub_value, base_name, disabled: disabled)
              end
            end

            content_tag(:div, class: 'row') { safe_join(fields_html) } +
              content_tag(:div, class: 'text-end mt-2') do
                button_tag('Remove', type: 'button', class: 'btn btn-sm btn-outline-danger',
                  disabled: disabled, data: { action: 'repeater#removeRow' })
              end
          end
        end
      end
    end
  end
end
