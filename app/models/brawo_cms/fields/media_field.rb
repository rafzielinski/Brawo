module BrawoCms
  module Fields
    class MediaField < BrawoCms::Field
      def initialize(definition)
        super
        @accept = definition[:accept] || "*/*"
      end

      def render_input(form, object, helper: nil)
        helper ||= field_helper
        helper.brawo_media_picker(
          form: form,
          name: @name,
          value: get_value(object),
          accept: @accept,
          disabled: @options[:disabled],
          input_html: @options.except(:disabled)
        )
      end

      def display_value(object)
        field_helper.brawo_media_display(get_value(object))
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
