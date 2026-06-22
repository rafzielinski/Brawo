module BrawoCms
  class TaxonomySerializer
    def initialize(taxonomy, taxonomy_type:)
      @taxonomy = taxonomy
      @taxonomy_type = taxonomy_type
    end

    def as_json
      {
        id: @taxonomy.id,
        taxonomy_type: @taxonomy_type.to_s,
        name: @taxonomy.name,
        slug: @taxonomy.slug,
        description: @taxonomy.description,
        fields: @taxonomy.fields || {},
        created_at: @taxonomy.created_at,
        updated_at: @taxonomy.updated_at
      }
    end
  end
end
