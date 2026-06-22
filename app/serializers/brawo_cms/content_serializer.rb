module BrawoCms
  class ContentSerializer
    def initialize(content, content_type:)
      @content = content
      @content_type = content_type
    end

    def as_json
      {
        id: @content.id,
        content_type: @content_type.to_s,
        title: @content.title,
        slug: @content.slug,
        description: @content.description,
        status: @content.status,
        published_at: @content.published_at,
        fields: @content.fields || {},
        created_at: @content.created_at,
        updated_at: @content.updated_at
      }
    end
  end
end
