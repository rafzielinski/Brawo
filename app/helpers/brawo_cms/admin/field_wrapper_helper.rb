module BrawoCms
  module Admin
    module FieldWrapperHelper
      DEFAULT_FIELD_WIDTH = '100'
      FIELD_ROW_CLASS = 'row brawo-fields'

      def field_wrapper_attrs(field_def)
        wrapper = (field_def[:wrapper] || {}).with_indifferent_access
        width = normalize_field_width(wrapper[:width])
        width_num = width.delete('%')

        classes = [
          'brawo-field-wrapper',
          field_bootstrap_col_class(width_num),
          'mb-3',
          wrapper[:class]
        ].compact

        attrs = {
          class: classes.join(' '),
          data: { field_width: width_num }
        }

        attrs.merge!(parse_wrapper_attr(wrapper[:attr] || wrapper[:attrs]))
        attrs
      end

      def field_bootstrap_col_class(width_num)
        width_num = width_num.to_i
        return 'col-12' if width_num >= 100

        cols = (width_num / 100.0 * 12).round.clamp(1, 12)
        "col-12 col-md-#{cols}"
      end

      def normalize_field_width(width)
        width_str = width.presence&.to_s&.strip || DEFAULT_FIELD_WIDTH
        return '100%' if width_str == '100'

        if width_str.match?(/\A\d+(\.\d+)?\z/)
          "#{width_str}%"
        elsif width_str.end_with?('%')
          width_str
        else
          width_str
        end
      end

      def render_field_group(form, fields, record, render_input:)
        content_tag(:div, class: FIELD_ROW_CLASS) do
          safe_join(fields.map { |field| render_wrapped_field(form, field, record, render_input: render_input) })
        end
      end

      def render_wrapped_field(form, field, record, render_input:)
        content_tag(:div, **field_wrapper_attrs(field)) do
          label = form.label(field[:name], field[:label] || field[:name].to_s.titleize, class: 'form-label')
          input = public_send(render_input, form, field, record)
          help = if field[:help_text].present?
                   content_tag(:small, field[:help_text], class: 'form-text text-muted')
                 end

          safe_join([label, input, help].compact)
        end
      end

      private

      def parse_wrapper_attr(attr)
        case attr
        when Hash
          attr.stringify_keys
        when String
          parse_html_attr_string(attr)
        else
          {}
        end
      end

      def parse_html_attr_string(str)
        attrs = {}
        str.scan(/([\w:-]+)=["']([^"']*)["']/) do |key, value|
          attrs[key] = value
        end
        attrs
      end
    end
  end
end
