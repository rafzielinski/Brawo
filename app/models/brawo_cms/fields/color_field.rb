module BrawoCms
  module Fields
    class ColorField < BrawoCms::Field
      def initialize(definition)
        super
        @swatches = definition[:swatches] || BrawoCms::Admin::ColorPickerHelper::DEFAULT_SWATCHES
        @alpha = definition.fetch(:alpha, true)
      end

      def render_input(form, object, helper: nil)
        helper ||= field_helper
        helper.brawo_color_picker(
          form: form,
          name: @name,
          value: get_value(object),
          swatches: @swatches,
          alpha: @alpha,
          disabled: @options[:disabled],
          input_html: @options.except(:disabled)
        )
      end

      def display_value(object)
        field_helper.brawo_color_display(get_value(object))
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
