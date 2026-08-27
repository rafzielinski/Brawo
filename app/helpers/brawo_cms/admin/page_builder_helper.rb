module BrawoCms
  module Admin
    module PageBuilderHelper
      include ApplicationHelper
      include ReorderMenuHelper
      include SidePanelHelper
      include CollapsibleHelper
      include BrawoCms::ErbFileRenderer

      PAGE_BUILDER_SIDE_PANEL_ID = "page-builder-side-panel"

      def render_page_builder(form, field_name, blocks, label: nil, available_blocks: BrawoCms.block_types)
        blocks = Array(blocks)
        @available_blocks = available_blocks

        if respond_to?(:content_for)
          content_for(:admin_side_panel) do
            render_page_builder_side_panel(blocks, available_block_types)
          end
        end

        content_tag(:div, class: 'page-builder', data: {
          controller: 'page-builder',
          page_builder_field_name_value: field_name,
          page_builder_form_prefix_value: form.object_name,
          page_builder_translations_value: page_builder_translations.to_json,
          action: 'sortable:sorted->page-builder#reindex click->page-builder#clearFocus keydown@window->page-builder#clearFocusOnEscape'
        }) do
          safe_join([
            render_canvas_area(form, field_name, blocks, label: label),
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
                data: { action: 'page-builder#openPanel', panel_section: 'structure' }) +
                button_tag(t('brawo.collapsible.collapse_all'), type: 'button',
                  class: 'btn btn-outline-secondary btn-sm',
                  data: { action: 'page-builder#toggleAllBlocksCollapse', page_builder_target: 'collapseAllBtn' }) +
                button_tag(type: 'button', class: 'btn btn-primary btn-sm',
                  data: { action: 'page-builder#openPanel', insert_position: insert_at, panel_section: 'add' }) do
                  t('brawo.page_builder.add_block')
                end
            end
        end
      end

      def render_add_block_button(position, insert_at)
        content_tag(:div, class: "page-builder-add-bar page-builder-add-bar--#{position}") do
          button_tag(type: 'button', class: 'btn btn-outline-secondary btn-sm',
            data: { action: 'page-builder#openPanel', insert_position: insert_at, panel_section: 'add' }) do
            t('brawo.page_builder.add_block')
          end
        end
      end

      def render_insert_zone(position)
        content_tag(:div, class: 'block-insert-zone', data: { insert_position: position }) do
          content_tag(:button, brawo_icon(:plus_lg, size: :sm), type: 'button', class: 'block-insert-zone-btn',
            title: t('brawo.page_builder.insert_block'),
            data: { action: 'page-builder#openPanel', insert_position: position, panel_section: 'add' })
        end
      end

      def render_page_builder_side_panel(blocks, block_types)
        content = BrawoCms::Admin::BaseController.render(
          partial: "brawo_cms/admin/page_builder/side_panel_content",
          locals: {
            blocks: blocks,
            outline_items: render_structure_items(blocks),
            block_buttons: render_block_type_buttons(block_types)
          },
          formats: [:html]
        )

        render_admin_side_panel(
          id: PAGE_BUILDER_SIDE_PANEL_ID,
          title: t("brawo.page_builder.panel_title"),
          content: content,
          controllers: "admin-side-panel page-builder-side-panel",
          data: { "page-builder-side-panel-page-builder-outlet": ".page-builder" }
        )
      end

      def render_structure_items(blocks)
        safe_join(blocks.each_with_index.map { |block, index| render_structure_item(block, index) })
      end

      def render_block_type_buttons(block_types)
        safe_join(block_types.map do |type_name, config|
          button_tag(config[:label], type: "button", class: "btn btn-outline-secondary text-start",
            data: { action: "page-builder-side-panel#pickBlockType", block_type: type_name })
        end)
      end

      def render_structure_item(block, index)
        block = block.with_indifferent_access
        label = block_type_label(block[:type])

        content_tag(:li, class: "page-builder-structure-item", data: {
          block_index: index,
          action: "click->page-builder-side-panel#focusBlock"
        }) do
          content_tag(:span, brawo_drag_handle,
            class: "page-builder-structure-item__handle brawo-icon-btn",
            title: t("brawo.page_builder.drag_to_reorder")) +
            content_tag(:span, class: "page-builder-structure-item__label") do
              content_tag(:strong, label)
            end
        end
      end

      private :render_structure_items, :render_block_type_buttons, :render_structure_item

      def render_page_builder_panel(blocks, block_types)
        render_page_builder_side_panel(blocks, block_types)
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
          drag_to_reorder: t('brawo.page_builder.drag_to_reorder'),
          collapse_all: t('brawo.collapsible.collapse_all'),
          expand_all: t('brawo.collapsible.expand_all')
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
          controller: 'collapsible',
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
            controller: 'collapsible',
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
        content_tag(:div, class: 'page-builder-block-header d-flex align-items-center gap-2',
          data: { action: 'click->page-builder#toggleBlockFocus' }) do
          content_tag(:span, brawo_drag_handle, class: 'drag-handle brawo-icon-btn', title: t('brawo.page_builder.drag_to_reorder')) +
            content_tag(:span, label, class: 'page-builder-block-type') +
            content_tag(:span, '', class: 'flex-grow-1') +
            render_block_menu(index) +
            brawo_collapsible_toggle
        end
      end

      def render_block_menu(_index)
        render_item_actions_dropdown(
          move_action: 'page-builder#moveBlock',
          remove_action: 'page-builder#removeBlock',
          extra_before_remove: [
            { label: t('brawo.page_builder.add_block_above'), action: 'page-builder#openPickerRelative', data: { insert_offset: 0, panel_section: 'add' } },
            { label: t('brawo.page_builder.add_block_below'), action: 'page-builder#openPickerRelative', data: { insert_offset: 1, panel_section: 'add' } },
            { label: t('brawo.collapsible.collapse'), action: 'collapsible#collapse' },
            { label: t('brawo.collapsible.expand'), action: 'collapsible#expand' }
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
          content_tag(:div, class: "brawo-field-toggle-row") do
            label_tag(input_name, label_text.html_safe, class: "brawo-field-toggle-row__label") +
              content_tag(:div, class: "brawo-field-toggle-row__control") do
                brawo_toggle(
                  name: input_name,
                  checked: field_value,
                  disabled: disabled
                )
              end
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
        when :color
          brawo_color_picker(
            name: input_name,
            value: field_value,
            swatches: field_def[:swatches],
            alpha: field_def[:alpha],
            disabled: disabled,
            input_html: options
          )
        when :icon
          brawo_icon_picker(
            name: input_name,
            value: field_value,
            variant: field_def[:variant] || :outline,
            icons: field_def[:choices],
            disabled: disabled,
            input_html: options
          )
        when :url
          brawo_url_field(
            name: input_name,
            value: field_value,
            default_scheme: field_def[:default_scheme],
            allowed_schemes: field_def[:allowed_schemes],
            required: sub_field.required,
            disabled: disabled,
            input_html: options
          )
        when :email
          brawo_email_field(
            name: input_name,
            value: field_value,
            required: sub_field.required,
            disabled: disabled,
            input_html: options
          )
        when :media
          brawo_media_picker(
            name: input_name,
            value: field_value,
            accept: field_def[:accept],
            disabled: disabled,
            input_html: options
          )
        else
          text_field_tag(input_name, field_value, options)
        end
      end

      def render_block_repeater(field_def, input_name, field_value, disabled: false)
        field_value = Array(field_value)
        repeater_name = field_def[:name]
        base_name = input_name

        content_tag(:div, class: 'repeater-field', data: {
          controller: 'collapsible repeater',
          repeater_field_name_value: repeater_name,
          action: 'sortable:sorted->repeater#reindex'
        }) do
          content_tag(:div, class: 'repeater-field-header d-flex align-items-center gap-2',
            data: { action: 'click->collapsible#toggleHeader' }) do
            brawo_collapsible_toggle +
              content_tag(:span, field_def[:label] || repeater_name.to_s.humanize, class: 'form-label mb-0 flex-grow-1')
          end +
            content_tag(:div, class: 'repeater-field-body') do
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
                button_tag(t('brawo.page_builder.add_row'), type: 'button', class: 'btn btn-sm btn-outline-secondary mt-2',
                  disabled: disabled, data: { action: 'repeater#addRow' })
            end
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

        row_label = index.to_s == 'INDEX' ? t('brawo.fields.item', number: 'N') : t('brawo.fields.item', number: index.to_i + 1)

        content_tag(:div, class: 'repeater-row card mb-2', data: { controller: 'collapsible', index: index }) do
          content_tag(:div, class: 'repeater-row-header d-flex align-items-center gap-2',
            data: { action: 'click->collapsible#toggleHeader' }) do
            brawo_collapsible_toggle +
              content_tag(:span, brawo_drag_handle, class: 'repeater-drag-handle brawo-icon-btn', title: t('brawo.page_builder.drag_to_reorder')) +
              content_tag(:span, row_label, class: 'repeater-row-label small text-muted flex-grow-1') +
              render_item_actions_dropdown(
                move_action: 'repeater#moveRow',
                remove_action: 'repeater#removeRow',
                disabled: disabled
              )
          end +
            content_tag(:div, class: 'card-body') do
              content_tag(:div, class: BrawoCms::Admin::FieldWrapperHelper::FIELD_ROW_CLASS) { safe_join(fields_html) }
            end
        end
      end
    end
  end
end
