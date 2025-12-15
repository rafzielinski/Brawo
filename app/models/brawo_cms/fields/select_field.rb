module BrawoCms
  module Fields
    class SelectField < BrawoCms::Field
      def render_input_field(form, options, object)
        select_options = {
          include_blank: @required ? false : "Select #{@label}"
        }
        form.select(@name, @choices, select_options, options.merge(class: 'form-select'))
      end
    end
  end
end

