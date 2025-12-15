module BrawoCms
  module Fields
    class NumberField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.number_field(@name, options)
      end
    end
  end
end

