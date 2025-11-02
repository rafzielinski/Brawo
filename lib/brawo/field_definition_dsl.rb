module Brawo
  class FieldDefinitionDsl
    def initialize(field_definitions)
      @field_definitions = field_definitions
    end

    def field(name, type, **options)
      field_def = FieldDefinition.new(name, type, options)
      @field_definitions << field_def
    end
  end
end