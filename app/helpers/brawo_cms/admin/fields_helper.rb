module BrawoCms
  module Admin
    module FieldsHelper
      def display_field_value(record, field)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.display_value(record)
      end

      def render_field_input(form, field, record)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.render_input(form, record)
      end
    end
  end
end
