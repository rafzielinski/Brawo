module BrawoCms
  module Fields
    class UrlField < BrawoCms::Field
      def initialize(definition)
        super
        @default_scheme = (definition[:default_scheme] || "https").to_s.downcase
        @allowed_schemes = definition[:allowed_schemes]
      end

      def render_input(form, object, helper: nil)
        helper ||= field_helper
        helper.brawo_url_field(
          form: form,
          name: @name,
          value: get_value(object),
          default_scheme: @default_scheme,
          allowed_schemes: @allowed_schemes,
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
