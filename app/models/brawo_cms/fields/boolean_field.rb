module BrawoCms
  module Fields
    class BooleanField < BrawoCms::Field
      def render_input(form, object, helper: nil)
        checked = object.get_field(@name)
        input_options = default_input_options.merge(@options).except(:off_label, :on_label, :class)
        off = { text: @options[:off_label] }
        on = { text: @options[:on_label] }

        helper.brawo_toggle(
          form: form,
          name: @name,
          checked: !!checked,
          off: off,
          on: on,
          disabled: @options[:disabled],
          input_html: { options: input_options }
        )
      end

      def format_value(value)
        value ? "✓ Yes" : "✗ No"
      end
    end
  end
end
