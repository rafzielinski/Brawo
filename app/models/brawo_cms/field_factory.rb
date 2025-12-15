module BrawoCms
  class FieldFactory
    TYPE_MAPPING = {
      string: Fields::StringField,
      text: Fields::StringField,
      textarea: Fields::TextField,
      number: Fields::NumberField,
      integer: Fields::NumberField,
      date: Fields::DateField,
      datetime: Fields::DatetimeField,
      boolean: Fields::BooleanField,
      checkbox: Fields::BooleanField,
      select: Fields::SelectField,
      taxonomy: Fields::TaxonomyField,
      reference: Fields::ReferenceField
    }.freeze

    def self.build(definition)
      type = (definition[:type] || :string).to_sym
      field_class = TYPE_MAPPING[type] || Fields::StringField
      field_class.new(definition)
    end

    def self.build_all(definitions)
      Array(definitions).map { |defn| build(defn) }
    end
  end
end

