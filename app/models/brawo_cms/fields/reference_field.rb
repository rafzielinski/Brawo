module BrawoCms
  module Fields
    class ReferenceField < BrawoCms::Field
      def initialize(definition)
        super
        @model_class = definition[:model_class]
      end

      def render_input_field(form, options, object)
        model_class = resolve_model_class(@model_class)
        return form.text_field(@name, options) unless model_class

        records = model_class.all.order(model_class.column_names.include?('title') ? :title : :name)
        choices = records.map do |record|
          label = record.respond_to?(:title) ? record.title : record.respond_to?(:name) ? record.name : record.id.to_s
          [label, record.id]
        end

        current_value = Array(object.get_field(@name)).compact.map(&:to_i)
        select_options = { selected: current_value }
        form.select(
          "#{@name}[]",
          choices,
          select_options,
          options.merge(multiple: true, class: 'form-select', size: [choices.length, 10].min)
        )
      end

      def format_value(value)
        return '-' unless value.present? && @model_class

        model_class = resolve_model_class(@model_class)
        return '-' unless model_class

        ids = Array(value).compact
        return '-' if ids.empty?

        items = model_class.where(id: ids)
        items.map { |item| item.respond_to?(:title) ? item.title : item.respond_to?(:name) ? item.name : item.id }.join(', ')
      rescue
        value.is_a?(Array) ? value.join(', ') : value.to_s
      end
    end
  end
end

