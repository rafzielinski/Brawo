module BrawoCms
  class Media < ActiveRecord::Base
    self.table_name = "brawo_cms_media"

    THUMBNAIL_SIZE = [200, 200].freeze

    has_one_attached :file

    validates :file, presence: true, on: :create

    scope :ordered, -> { order(created_at: :desc) }

    scope :matching_accept, lambda { |accept|
      return all if accept.blank?

      relation = joins(file_attachment: :blob)

      if accept.to_s.end_with?("*")
        prefix = accept.to_s.chomp("*")
        relation.where("active_storage_blobs.content_type LIKE ?", "#{prefix}%")
      else
        relation.where(active_storage_blobs: { content_type: accept.to_s })
      end
    }

    scope :search_query, lambda { |query|
      return all if query.blank?

      term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s)}%"
      relation = left_joins(file_attachment: :blob)
      relation.where("brawo_cms_media.title ILIKE :term OR active_storage_blobs.filename ILIKE :term", term: term)
    }

    def image?
      content_type&.start_with?("image/")
    end

    def content_type
      file.attached? ? file.blob.content_type : nil
    end

    def filename
      file.attached? ? file.filename.to_s : nil
    end

    def byte_size
      file.attached? ? file.blob.byte_size : nil
    end

    def display_title
      title.presence || filename || "Media ##{id}"
    end

    def file_url(only_path: true)
      return nil unless file.attached?

      Rails.application.routes.url_helpers.rails_blob_path(file, only_path: only_path)
    end

    def thumbnail_url(only_path: true)
      return nil unless image? && file.attached?

      Rails.application.routes.url_helpers.rails_representation_path(
        thumbnail_variant,
        only_path: only_path
      )
    end

    def thumbnail_variant
      file.variant(resize_to_fill: THUMBNAIL_SIZE)
    end
  end
end
