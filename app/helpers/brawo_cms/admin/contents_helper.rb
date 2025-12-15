module BrawoCms
  module Admin
    module ContentsHelper
      def status_badge_class(status)
        case status
        when 'published'
          'bg-success'
        when 'draft'
          'bg-warning'
        when 'archived'
          'bg-secondary'
        else
          'bg-info'
        end
      end

      def display_field_value(content, field)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.display_value(content)
      end

      def render_field_input(form, field, content)
        field_instance = field.is_a?(BrawoCms::Field) ? field : BrawoCms::FieldFactory.build(field)
        field_instance.render_input(form, content)
      end
    end
  end
end

