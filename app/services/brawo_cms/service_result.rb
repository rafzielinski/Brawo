module BrawoCms
  class ServiceResult
    attr_reader :record, :records, :errors, :error_code
    attr_accessor :slug_adjusted, :slug_conflict

    def initialize(success:, record: nil, records: nil, errors: {}, error_code: nil, slug_conflict: nil)
      @success = success
      @record = record
      @records = records
      @errors = errors
      @error_code = error_code
      @slug_conflict = slug_conflict
    end

    def success?
      @success
    end

    def failure?
      !success?
    end

    def slug_conflict?
      slug_conflict.present?
    end

    def self.success(record = nil, records: nil)
      new(success: true, record: record, records: records)
    end

    def self.failure(record: nil, errors: {}, error_code: :unprocessable_entity, slug_conflict: nil)
      new(
        success: false,
        record: record,
        errors: errors,
        error_code: error_code,
        slug_conflict: slug_conflict
      )
    end

    def self.not_found(message = "Not found")
      new(success: false, errors: { base: [message] }, error_code: :not_found)
    end
  end
end
