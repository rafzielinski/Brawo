module BrawoCms
  class ContentService
    BASE_KEYS = %i[title slug description status published_at].freeze

    class << self
      def list(type:)
        config = type_config(type)
        return type_not_found(type) unless config

        records = config[:class].all.order(created_at: :desc)
        ServiceResult.success(records: records)
      end

      def find(type:, id:)
        config = type_config(type)
        return type_not_found(type) unless config

        record = config[:class].find_by(id: id)
        return ServiceResult.not_found("Content not found") unless record

        ServiceResult.success(record)
      end

      def create(type:, attributes:)
        config = type_config(type)
        return type_not_found(type) unless config

        record = config[:class].new(attributes)
        save_record(record)
      end

      def update(type:, id:, attributes:)
        result = find(type: type, id: id)
        return result if result.failure?

        record = result.record
        record.assign_attributes(attributes)
        save_record(record)
      end

      def destroy(type:, id:)
        result = find(type: type, id: id)
        return result if result.failure?

        result.record.destroy
        ServiceResult.success
      end

      def build_attributes(type_config:, params:, wrap_key: :content)
        ParamsBuilder.from_request(
          type_config: type_config,
          base_keys: BASE_KEYS,
          params: params,
          wrap_key: wrap_key
        )
      end

      def build_attributes_from_hash(type_config:, raw_hash:)
        ParamsBuilder.from_hash(
          type_config: type_config,
          base_keys: BASE_KEYS,
          raw_hash: raw_hash
        )
      end

      def type_config(type)
        BrawoCms.content_types[type.to_sym]
      end

      private

      def save_record(record)
        if record.save
          ServiceResult.success(record)
        else
          ServiceResult.failure(record: record, errors: record.errors.to_hash)
        end
      end

      def type_not_found(type)
        ServiceResult.failure(
          errors: { content_type: ["'#{type}' not found"] },
          error_code: :not_found
        )
      end
    end
  end
end
