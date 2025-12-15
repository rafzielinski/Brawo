module BrawoCms
  module Admin
    module TaxonomiesHelper
      def display_field_value(taxonomy, field)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.display_value(taxonomy)
      end

      def render_field_input(form, field, taxonomy)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.render_input(form, taxonomy)
      end
    end
  end
end

