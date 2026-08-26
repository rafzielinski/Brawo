module BrawoCms
  module Admin
    module IconPickerHelper
      include IconsHelper

      ICON_PICKER_PARTIAL = "brawo_cms/admin/shared/icon_picker"

      def brawo_icon_picker(**options)
        BrawoCms::Admin::BaseController.render(
          partial: ICON_PICKER_PARTIAL,
          locals: build_icon_picker_locals(options),
          formats: [:html]
        )
      end

      def brawo_icon_display(name, variant: :outline)
        if name.blank?
          return content_tag(:span, I18n.t("brawo.fields.empty_value"), class: "text-muted")
        end

        tag.span(class: "brawo-icon-display") do
          brawo_icon(name, variant: variant) +
            tag.span(name.to_s, class: "brawo-icon-display__name")
        end
      end

      def bootstrap_icons_manifest_path
        asset_path("brawo_cms/bootstrap_icons.json")
      end

      private

      def build_icon_picker_locals(options)
        name = options[:name]
        value = options[:value]
        variant = (options[:variant] || :outline).to_sym
        icons = normalize_icon_choices(options[:icons])
        disabled = options[:disabled] || false
        input_html = (options[:input_html] || {}).deep_dup
        input_class = class_names("form-control brawo-icon-picker__input", input_html.delete(:class))
        picker_id = "icon_picker_#{name.to_s.gsub(/[^a-z0-9]+/i, "_")}"

        input_field =
          if options[:form]
            form = options[:form]
            input_options = input_html.merge(
              class: input_class,
              disabled: disabled,
              data: (input_html[:data] || {}).merge(icon_picker_target: "input")
            )
            form.text_field(name, input_options.merge(value: value))
          else
            text_field_tag(
              name,
              value,
              input_html.merge(
                class: input_class,
                disabled: disabled,
                data: { icon_picker_target: "input" }
              )
            )
          end

        {
          value: value,
          variant: variant,
          icons: icons,
          icons_url: bootstrap_icons_manifest_path,
          disabled: disabled,
          input_field: input_field,
          picker_id: picker_id
        }
      end

      def normalize_icon_choices(choices)
        return [] if choices.blank?

        choices.map do |choice|
          choice.is_a?(Array) ? choice[1].to_s : choice.to_s
        end
      end
    end
  end
end
