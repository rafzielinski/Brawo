module BrawoCms
  module Fields
    class TaxonomyField < BrawoCms::Field
      def initialize(definition)
        super
        @taxonomy_type = definition[:taxonomy_type]
      end

      def render_input_field(form, options, object)
        return form.text_field(@name, options) unless @taxonomy_type

        taxonomy_config = BrawoCms.taxonomy_types[@taxonomy_type]
        return form.text_field(@name, options) unless taxonomy_config

        taxonomy_class = taxonomy_config[:class]
        taxonomy_entries = taxonomy_class.all.order(:name)
        choices = taxonomy_entries.map { |entry| [entry.name, entry.id] }

        select_options = {
          include_blank: @required ? false : "Select #{@label}"
        }
        form.select(@name, choices, select_options, options.merge(class: 'form-select'))
      end

      def format_value(value)
        return '-' unless value.present? && @taxonomy_type

        taxonomy_config = BrawoCms.taxonomy_types[@taxonomy_type]
        return value.to_s unless taxonomy_config

        taxonomy_class = taxonomy_config[:class]
        taxonomy_item = taxonomy_class.find_by(id: value)
        taxonomy_item ? taxonomy_item.name : '-'
      rescue
        value.to_s
      end
    end
  end
end

