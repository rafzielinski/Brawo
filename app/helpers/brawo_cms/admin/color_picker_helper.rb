module BrawoCms
  module Admin
    module ColorPickerHelper
      DEFAULT_SWATCHES = [
        "#48BB78", "#4299E1", "#667EEA", "#ED8936",
        "#F56565", "#ECC94B", "#38B2AC", "#A0AEC0"
      ].freeze

      COLOR_PICKER_PARTIAL = "brawo_cms/admin/shared/color_picker"

      def brawo_color_picker(**options)
        BrawoCms::Admin::BaseController.render(
          partial: COLOR_PICKER_PARTIAL,
          locals: build_color_picker_locals(options),
          formats: [:html]
        )
      end

      def brawo_color_display(hex)
        if hex.blank?
          return content_tag(:span, I18n.t("brawo.fields.empty_value"), class: "text-muted")
        end

        tag.span(class: "brawo-color-display") do
          tag.span("", class: "brawo-color-display__swatch", style: "background-color: #{hex}") +
            tag.span(hex, class: "brawo-color-display__text")
        end
      end

      private

      def build_color_picker_locals(options)
        name = options[:name]
        value = options[:value]
        swatches = options[:swatches] || DEFAULT_SWATCHES
        alpha = options[:alpha] || false
        disabled = options[:disabled] || false
        input_html = (options[:input_html] || {}).deep_dup
        input_class = class_names("form-control brawo-color-picker__input", input_html.delete(:class))
        picker_id = "color_picker_#{name.to_s.gsub(/[^a-z0-9]+/i, '_')}"

        input_field =
          if options[:form]
            form = options[:form]
            input_options = input_html.merge(
              class: input_class,
              disabled: disabled,
              data: (input_html[:data] || {}).merge(color_picker_target: "input")
            )
            form.text_field(name, input_options.merge(value: value, id: "#{picker_id}_input"))
          else
            text_field_tag(
              name,
              value,
              input_html.merge(
                class: input_class,
                id: "#{picker_id}_input",
                disabled: disabled,
                data: { color_picker_target: "input" }
              )
            )
          end

        {
          value: value,
          default_color: value.presence || "#000000",
          swatches: swatches,
          alpha: alpha,
          disabled: disabled,
          input_field: input_field,
          picker_id: picker_id
        }
      end
    end
  end
end
