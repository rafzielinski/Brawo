module BrawoCms
  module Fields
    class DatetimeField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.datetime_field(@name, options)
      end

      def format_value(value)
        return '-' unless value.present?
        DateTime.parse(value).strftime("%B %d, %Y at %I:%M %p")
      rescue
        value.to_s
      end
    end
  end
end

