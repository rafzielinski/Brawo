module BrawoCms
  module Admin
    module ToggleHelper
      ToggleSide = Struct.new(:text, :icon, :aria_label, keyword_init: true)

      TOGGLE_PARTIAL = "brawo_cms/admin/shared/toggle"

      def brawo_toggle(**options)
        BrawoCms::Admin::BaseController.render(
          partial: TOGGLE_PARTIAL,
          locals: build_toggle_locals(options),
          formats: [:html]
        )
      end

      def brawo_toggle_pen_icon
        toggle_icon_svg("M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168l10-10zM11.207 2.5 13.5 4.793 14.793 3.5 12.5 1.207 11.207 2.5zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293l6.5-6.5zm-9.761 5.175-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325z")
      end

      def brawo_toggle_eye_icon
        toggle_icon_svg("M16 8s-3-5.5-8-5.5S0 8 0 8s3 5.5 8 5.5S16 8 16 8zM1.173 8a13.133 13.133 0 0 1 1.66-2.043C4.12 4.668 5.88 3.5 8 3.5c2.12 0 3.879 1.168 5.168 2.457A13.133 13.133 0 0 1 14.828 8q-.004.087-.007.17a3.001 3.001 0 0 0-.581-1.61C12.879 4.668 11.119 3.5 9 3.5c-2.12 0-3.879 1.168-5.168 2.457A13.133 13.133 0 0 0 1.172 8zm4.197 5.178a.811.811 0 0 1-.438-.442c-.397-.819-1.55-.821-1.957 0a.889.889 0 0 1-1.511-.057A12.97 12.97 0 0 1 1.73 8.008C2.602 6.329 4.87 4.5 8 4.5c3.13 0 5.268 1.829 6.16 3.508a12.97 12.97 0 0 1-.59 4.992 1.889 1.889 0 0 1-1.512.057 1.853 1.853 0 0 1-.438-.442 2.042 2.042 0 0 0-1.947 0zM8 5.5a3 3 0 1 0 0 6 3 3 0 0 0 0-6zm0 5a2 2 0 1 1 0-4 2 2 0 0 1 0 4z")
      end

      def toggle_side_content(side)
        parts = []
        if side.icon.present?
          parts << content_tag(:span, side.icon, class: "brawo-toggle__icon")
        end
        if side.text.present?
          parts << content_tag(:span, side.text, class: "brawo-toggle__label")
        end
        safe_join(parts)
      end

      def toggle_side_aria_label(side, fallback)
        side.aria_label.presence || side.text.presence || fallback
      end

      private

      def build_toggle_locals(options)
        off = normalize_toggle_side(options[:off] || {})
        on = normalize_toggle_side(options[:on] || {})
        off_state = options.fetch(:off_state, "off").to_s
        on_state = options.fetch(:on_state, "on").to_s
        variant = options[:variant] || infer_toggle_variant(off, on)
        use_state = options.key?(:state)
        state = (options[:state] || off_state).to_s
        checked = if use_state
                    state == on_state
                  else
                    options.fetch(:checked, false)
                  end

        {
          variant: variant,
          size: (options[:size] || :md).to_s,
          use_state: use_state,
          state: state,
          off_state: off_state,
          on_state: on_state,
          checked: checked,
          off: off,
          on: on,
          has_segment_content: side_has_content?(off) || side_has_content?(on),
          disabled: options[:disabled] || false,
          disabled_on: options[:disabled_on] || false,
          checkbox: build_toggle_checkbox(options),
          wrapper_html: options[:html] || {},
          switch_label: options[:switch_label]
        }
      end

      def normalize_toggle_side(side)
        side = side.with_indifferent_access
        ToggleSide.new(
          text: side[:text],
          icon: side[:icon],
          aria_label: side[:aria_label]
        )
      end

      def infer_toggle_variant(off, on)
        if side_has_content?(off) || side_has_content?(on)
          :segmented
        else
          :switch
        end
      end

      def side_has_content?(side)
        side.text.present? || side.icon.present?
      end

      def build_toggle_checkbox(options)
        if options[:form] && options[:name]
          build_form_toggle_checkbox(options)
        elsif options[:name]
          build_tag_toggle_checkbox(options)
        end
      end

      def build_form_toggle_checkbox(options)
        form = options[:form]
        name = options[:name]
        input_html = (options[:input_html] || {}).deep_dup
        input_options = input_html.delete(:options) || {}
        input_options[:class] = class_names("brawo-toggle__input", "visually-hidden", input_options[:class])
        input_options[:data] = (input_options[:data] || {}).merge(
          toggle_target: "input",
          action: "change->toggle#syncFromInput"
        )
        input_options[:disabled] = true if options[:disabled]
        input_options[:id] = input_html[:id] if input_html[:id]

        hidden_field = form.hidden_field(name, value: "0", id: nil)
        checkbox = form.check_box(name, input_options, "1", "0")
        hidden_field + checkbox
      end

      def build_tag_toggle_checkbox(options)
        name = options[:name]
        input_html = (options[:input_html] || {}).deep_dup
        input_options = input_html.delete(:options) || {}
        input_options[:class] = class_names("brawo-toggle__input", "visually-hidden", input_options[:class])
        input_options[:data] = (input_options[:data] || {}).merge(
          toggle_target: "input",
          action: "change->toggle#syncFromInput"
        )
        input_options[:disabled] = true if options[:disabled]
        input_options[:id] = input_html[:id] if input_html[:id]

        hidden_field_tag(name, "0", id: nil) +
          check_box_tag(name, "1", options.fetch(:checked, false), input_options)
      end

      def toggle_icon_svg(path_d)
        tag.svg(
          xmlns: "http://www.w3.org/2000/svg",
          width: 14,
          height: 14,
          fill: "currentColor",
          viewBox: "0 0 16 16",
          "aria-hidden": true
        ) do
          tag.path(d: path_d)
        end
      end
    end
  end
end
