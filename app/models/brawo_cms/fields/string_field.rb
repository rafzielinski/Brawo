module BrawoCms
  module Fields
    class StringField < BrawoCms::Field
      def render_input_field(form, options, object)
        form.text_field(@name, options)
      end
    end
  end
end

