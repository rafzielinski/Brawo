module BrawoCms
  module Fields
    class DateField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.date_field(@name, options)
      end

      def format_value(value)
        return '-' unless value.present?
        Date.parse(value).strftime("%B %d, %Y")
      rescue
        value.to_s
      end
    end
  end
end

