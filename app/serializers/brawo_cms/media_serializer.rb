module BrawoCms
  class MediaSerializer
    def initialize(media)
      @media = media
    end

    def as_json
      {
        id: @media.id,
        title: @media.title,
        alt_text: @media.alt_text,
        filename: @media.filename,
        content_type: @media.content_type,
        byte_size: @media.byte_size,
        url: @media.file_url,
        thumbnail_url: @media.thumbnail_url,
        created_at: @media.created_at,
        updated_at: @media.updated_at
      }
    end
  end
end
