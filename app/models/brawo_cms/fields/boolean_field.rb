module BrawoCms
  module Fields
    class BooleanField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.check_box(@name, options.merge(class: 'form-check-input'))
      end

      def format_value(value)
        value ? '✓ Yes' : '✗ No'
      end
    end
  end
end

