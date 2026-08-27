module BrawoCms
  class MediaService
    ATTRIBUTE_KEYS = %i[title alt_text file signed_id].freeze

    class << self
      def list(accept: nil, q: nil)
        records = Media.ordered.matching_accept(accept).search_query(q).distinct
        ServiceResult.success(records: records)
      end

      def find(id:)
        record = RecordFinder.find(Media.all, id)
        return ServiceResult.not_found("Media not found") unless record

        ServiceResult.success(record)
      end

      def create(attributes:)
        record = Media.new(metadata_attributes(attributes))
        attach_file(record, attributes)
        save_record(record)
      end

      def update(id:, attributes:)
        result = find(id: id)
        return result if result.failure?

        record = result.record
        record.assign_attributes(metadata_attributes(attributes))
        attach_file(record, attributes) if attributes[:file].present? || attributes[:signed_id].present?
        save_record(record)
      end

      def destroy(id:)
        result = find(id: id)
        return result if result.failure?

        result.record.destroy
        ServiceResult.success
      end

      def build_attributes(params:, wrap_key: :media)
        raw = params[wrap_key]
        return {} if raw.blank?

        hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
        hash.symbolize_keys.slice(*ATTRIBUTE_KEYS)
      end

      def build_attributes_from_hash(raw_hash:)
        raw_hash.deep_symbolize_keys.slice(*ATTRIBUTE_KEYS)
      end

      private

      def metadata_attributes(attributes)
        attributes.slice(:title, :alt_text)
      end

      def attach_file(record, attributes)
        if attributes[:file].present?
          record.file.attach(attributes[:file])
        elsif attributes[:signed_id].present?
          record.file.attach(attributes[:signed_id])
        end
      end

      def save_record(record)
        if record.save
          ServiceResult.success(record)
        else
          ServiceResult.failure(record: record, errors: record.errors.to_hash)
        end
      end
    end
  end
end
