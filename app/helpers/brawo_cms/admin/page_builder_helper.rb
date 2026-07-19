module BrawoCms
  module Admin
    module PageBuilderHelper
      include ApplicationHelper
      include ReorderMenuHelper
      include BrawoCms::ErbFileRenderer

      def render_page_builder(form, field_name, blocks, label: nil, available_blocks: BrawoCms.block_types)
        blocks = Array(blocks)
        @available_blocks = available_blocks

        content_tag(:div, class: 'page-builder outline-collapsed', data: {
          controller: 'page-builder',
          page_builder_field_name_value: field_name,
          page_builder_form_prefix_value: form.object_name,
          page_builder_translations_value: page_builder_translations.to_json,
          action: 'sortable:sorted->page-builder#reindex keydown@window->page-builder#closePickerOnEscape'
        }) do
          safe_join([
            content_tag(:div, class: 'page-builder-layout') do
              render_canvas_area(form, field_name, blocks, label: label) + render_outline_panel(blocks)
            end,
            render_block_picker,
            render_templates(form, field_name)
          ])
        end
      end

      def render_canvas_area(form, field_name, blocks, label: nil)
        content_tag(:div, class: 'page-builder-workspace') do
          safe_join([
            render_toolbar(label, 0),
            content_tag(:div, class: 'page-builder-canvas', data: {
              controller: 'sortable',
              sortable_handle_value: '.drag-handle',
              page_builder_target: 'canvas'
            }) do
              safe_join(build_canvas_children(form, field_name, blocks))
            end,
            render_add_block_button('bottom', blocks.size),
            content_tag(:p, t('brawo.page_builder.empty'),
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

      def render_toolbar(label, insert_at)
        content_tag(:div, class: 'page-builder-toolbar') do
          content_tag(:h5, label.presence || t('brawo.page_builder.default_label'), class: 'page-builder-title mb-0') +
            content_tag(:div, class: 'page-builder-toolbar-actions') do
              button_tag(t('brawo.page_builder.structure'), type: 'button',
                class: 'btn btn-outline-secondary btn-sm page-builder-structure-btn',
                data: { action: 'page-builder#toggleOutline' }) +
                button_tag(type: 'button', class: 'btn btn-outline-primary btn-sm',
                  data: { action: 'page-builder#openPicker', insert_position: insert_at }) do
                  t('brawo.page_builder.add_block')
                end
            end
        end
      end

      def render_add_block_button(position, insert_at)
        content_tag(:div, class: "page-builder-add-bar page-builder-add-bar--#{position}") do
          button_tag(type: 'button', class: 'btn btn-outline-primary btn-sm',
            data: { action: 'page-builder#openPicker', insert_position: insert_at }) do
            t('brawo.page_builder.add_block')
          end
        end
      end

      def render_insert_zone(position)
        content_tag(:div, class: 'block-insert-zone', data: { insert_position: position }) do
          content_tag(:button, '+', type: 'button', class: 'block-insert-zone-btn',
            title: t('brawo.page_builder.insert_block'),
            data: { action: 'page-builder#openPicker', insert_position: position })
        end
      end

      def render_block_picker
        content_tag(:div, class: 'page-builder-picker offcanvas offcanvas-end', tabindex: '-1',
          data: { page_builder_target: 'picker' }) do
          content_tag(:div, class: 'offcanvas-header') do
            content_tag(:h5, t('brawo.page_builder.choose_block_type'), class: 'offcanvas-title') +
              button_tag(type: 'button', class: 'btn-close',
                data: { action: 'page-builder#closePicker' }, aria: { label: t('brawo.layout.close') })
          end +
            content_tag(:div, class: 'offcanvas-body') do
              content_tag(:div, class: 'd-grid gap-2') do
                safe_join(available_block_types.map do |type_name, config|
                  button_tag(config[:label], type: 'button', class: 'btn btn-outline-secondary text-start',
                    data: { action: 'page-builder#pickBlockType', block_type: type_name })
                end)
              end
            end
        end
      end

      def render_outline_panel(blocks)
        content_tag(:aside, class: 'page-builder-outline is-collapsed', data: { page_builder_target: 'outlinePanel' }) do
          content_tag(:div, class: 'page-builder-outline-header') do
            content_tag(:h6, t('brawo.page_builder.structure'), class: 'mb-0') +
              button_tag(type: 'button', class: 'btn btn-sm btn-link page-builder-outline-close',
                data: { action: 'page-builder#toggleOutline' }, aria: { label: t('brawo.page_builder.close_panel') }) { '×' }
          end +
            content_tag(:ul, class: 'page-builder-outline-list list-unstyled mb-0',
              data: { controller: 'sortable', sortable_handle_value: '.outline-drag-handle',
                action: 'sortable:sorted->page-builder#reindexFromOutline',
                page_builder_target: 'outline' }) do
              safe_join(blocks.each_with_index.map do |block, index|
                render_outline_item(block, index)
              end)
            end
        end
      end

      def render_outline_item(block, index)
        block = block.with_indifferent_access
        block_type = block[:type]
        label = block_type_label(block_type)

        content_tag(:li, class: 'page-builder-outline-item', data: {
          block_index: index,
          action: 'click->page-builder#focusBlock'
        }) do
          content_tag(:span, '⋮⋮', class: 'outline-drag-handle', title: t('brawo.page_builder.drag_to_reorder')) +
            content_tag(:span, class: 'outline-item-label') do
              content_tag(:strong, label)
            end
        end
      end

      def render_templates(form, field_name)
        content_tag(:div, class: 'page-builder-templates') do
          safe_join(available_block_types.map do |type_name, config|
            render_block_template(form, field_name, type_name, config)
          end)
        end
      end

      def available_block_types
        @available_blocks || BrawoCms.block_types
      end

      def page_builder_translations
        {
          insert_block: t('brawo.page_builder.insert_block'),
          drag_to_reorder: t('brawo.page_builder.drag_to_reorder')
        }
      end

      private :available_block_types

      def render_block_row(form, field_name, block, index)
        block = block.with_indifferent_access if block.respond_to?(:with_indifferent_access)
        block_type = block[:type] || block['type']
        block_data = block[:data] || block['data'] || {}
        type_config = BrawoCms.block_type(block_type)
        return '' unless type_config

        content_tag(:div, class: 'page-builder-block card', data: {
          block_type: block_type,
          block_label: type_config[:label],
          block_index: index
        }) do
          block_header(type_config[:label], index) +
            content_tag(:div, class: 'card-body') do
              hidden_field_tag("#{form.object_name}[#{field_name}][#{index}][type]", block_type) +
                content_tag(:div, class: 'block-fields') do
                if type_config[:admin_template].present?
                  render_erb_file(type_config[:admin_template],
                    form: form, field_name: field_name, block_index: index, data: block_data)
                else
                  render_block_data_fields(form, field_name, index, type_config[:fields], block_data)
                end
              end
          end
        end
      end

      def render_block_template(form, field_name, type_name, config)
        content_tag(:div, class: 'page-builder-template', data: { block_type: type_name }) do
          content_tag(:div, class: 'page-builder-block card', data: {
            block_type: type_name,
            block_label: config[:label],
            block_index: 'INDEX'
          }) do
            block_header(config[:label], 'INDEX') +
              content_tag(:div, class: 'card-body') do
                hidden_field_tag("#{form.object_name}[#{field_name}][INDEX][type]", type_name, disabled: true) +
                  content_tag(:div, class: 'block-fields') do
                  render_block_data_fields(form, field_name, 'INDEX', config[:fields], {}, disabled: true)
                end
            end
          end
        end
      end

      def block_header(label, index)
        content_tag(:div, class: 'page-builder-block-header d-flex align-items-center gap-2') do
          content_tag(:span, '⋮⋮', class: 'drag-handle text-muted', title: t('brawo.page_builder.drag_to_reorder')) +
            content_tag(:span, label, class: 'page-builder-block-type') +
            content_tag(:span, '', class: 'flex-grow-1') +
            render_block_menu(index)
        end
      end

      def render_block_menu(_index)
        render_item_actions_dropdown(
          move_action: 'page-builder#moveBlock',
          remove_action: 'page-builder#removeBlock',
          extra_before_remove: [
            { label: t('brawo.page_builder.add_block_above'), action: 'page-builder#openPickerRelative', data: { insert_offset: 0 } },
            { label: t('brawo.page_builder.add_block_below'), action: 'page-builder#openPickerRelative', data: { insert_offset: 1 } }
          ]
        )
      end

      def block_type_label(block_type)
        type_config = BrawoCms.block_type(block_type)
        type_config ? type_config[:label] : block_type.to_s.humanize
      end

      def render_block_data_fields(form, field_name, block_index, field_defs, data, disabled: false)
        data = data.with_indifferent_access if data.respond_to?(:with_indifferent_access)
        prefix = "#{form.object_name}[#{field_name}][#{block_index}][data]"

        content_tag(:div, class: BrawoCms::Admin::FieldWrapperHelper::FIELD_ROW_CLASS) do
          safe_join(field_defs.map do |field_def|
            sub_field = BrawoCms::FieldFactory.build(field_def)
            field_key = sub_field.name.to_s
            field_value = data[field_key] || data[field_key.to_sym]
            input_name = "#{prefix}[#{field_key}]"

            content_tag(:div, **field_wrapper_attrs(field_def)) do
              render_block_field_input(sub_field, field_def, input_name, field_value, prefix, disabled: disabled)
            end
          end)
        end
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
          repeater_field_name_value: repeater_name,
          action: 'sortable:sorted->repeater#reindex'
        }) do
          content_tag(:label, field_def[:label] || repeater_name.to_s.humanize, class: 'form-label') +
            content_tag(:div, class: 'repeater-items', data: {
              controller: 'sortable',
              sortable_handle_value: '.repeater-drag-handle'
            }) do
              rows = field_value.each_with_index.map do |item, idx|
                render_block_repeater_row(field_def, base_name, item, idx, disabled: disabled)
              end
              template = content_tag(:div, class: 'repeater-template') do
                render_block_repeater_row(field_def, base_name, {}, 'INDEX', disabled: disabled)
              end
              safe_join(rows) + template
            end +
            button_tag(t('brawo.page_builder.add_row'), type: 'button', class: 'btn btn-sm btn-outline-primary mt-2',
              disabled: disabled, data: { action: 'repeater#addRow' })
        end
      end

      def render_block_repeater_row(field_def, base_name, item_data, index, disabled: false)
        item_data = item_data.with_indifferent_access if item_data.respond_to?(:with_indifferent_access)
        sub_fields = field_def[:sub_fields] || []

        fields_html = sub_fields.map do |sub_field_def|
          sub_field = BrawoCms::FieldFactory.build(sub_field_def)
          sub_name = "#{base_name}[#{index}][#{sub_field.name}]"
          sub_value = item_data[sub_field.name.to_s] || item_data[sub_field.name.to_sym]

          content_tag(:div, **field_wrapper_attrs(sub_field_def)) do
            render_block_field_input(sub_field, sub_field_def, sub_name, sub_value, base_name, disabled: disabled)
          end
        end

        content_tag(:div, class: 'repeater-row card mb-2', data: { index: index }) do
          content_tag(:div, class: 'card-body') do
            content_tag(:div, class: 'repeater-row-header d-flex align-items-center gap-2 mb-2') do
              content_tag(:span, '⋮⋮', class: 'repeater-drag-handle text-muted', title: t('brawo.page_builder.drag_to_reorder')) +
                content_tag(:span, '', class: 'flex-grow-1') +
                render_item_actions_dropdown(
                  move_action: 'repeater#moveRow',
                  remove_action: 'repeater#removeRow',
                  disabled: disabled
                )
            end +
              content_tag(:div, class: BrawoCms::Admin::FieldWrapperHelper::FIELD_ROW_CLASS) { safe_join(fields_html) }
          end
        end
      end
    end
  end
end
