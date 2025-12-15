module BrawoCms
  module Fields
    class TextField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.text_area(@name, options.merge(rows: 5))
      end

      def format_value(value)
        return '-' unless value.present?
        ActionController::Base.helpers.simple_format(value)
      end
    end
  end
end

