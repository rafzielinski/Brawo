module BrawoCms
  module Fields
    class IconField < BrawoCms::Field
      def initialize(definition)
        super
        @variant = (definition[:variant] || :outline).to_sym
        @icon_choices = definition[:choices]
      end

      def render_input(form, object, helper: nil)
        helper ||= field_helper
        helper.brawo_icon_picker(
          form: form,
          name: @name,
          value: get_value(object),
          variant: @variant,
          icons: @icon_choices,
          disabled: @options[:disabled],
          input_html: @options.except(:disabled)
        )
      end

      def display_value(object)
        field_helper.brawo_icon_display(get_value(object), variant: @variant)
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
