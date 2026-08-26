module BrawoCms
  module Fields
    class EmailField < BrawoCms::Field
      def render_input(form, object, helper: nil)
        helper ||= field_helper
        helper.brawo_email_field(
          form: form,
          name: @name,
          value: get_value(object),
          required: @required,
          disabled: @options[:disabled],
          input_html: @options.except(:disabled)
        )
      end

      private

      def field_helper
        helper = ActionController::Base.helpers
        helper.extend(BrawoCms::Admin::ApplicationHelper)
        helper
      end
    end
  end
end
