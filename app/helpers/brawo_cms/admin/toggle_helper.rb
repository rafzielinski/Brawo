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
        brawo_icon(:pencil, size: :sm)
      end

      def brawo_toggle_eye_icon
        brawo_icon(:eye, size: :sm)
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
    end
  end
end
