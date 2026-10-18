# frozen_string_literal: true

require "bcrypt"

module BrawoCms
  class AccountService
    ATTRIBUTE_KEYS = %i[email role status password password_confirmation].freeze
    PROFILE_ATTRIBUTE_KEYS = %i[email password password_confirmation].freeze

    class << self
      def list
        records = Account.order(:email)
        ServiceResult.success(records: records)
      end

      def find(id:)
        record = RecordFinder.find(Account.all, id)
        return ServiceResult.not_found("User not found") unless record

        ServiceResult.success(record)
      end

      def create(attributes:)
        record = Account.new(account_attributes(attributes))
        apply_password(record, attributes[:password])
        save_record(record)
      end

      def update(id:, attributes:, actor: nil)
        result = find(id: id)
        return result if result.failure?

        record = result.record
        return ServiceResult.failure(record: record, errors: { base: [I18n.t("brawo.users.errors.last_super_admin")] }) if
          would_remove_last_super_admin?(record, attributes, actor)

        record.assign_attributes(account_attributes(attributes))
        apply_password(record, attributes[:password]) if attributes[:password].present?
        save_record(record)
      end

      def update_profile(account:, attributes:)
        account.assign_attributes(profile_attributes(attributes))
        apply_password(account, attributes[:password]) if attributes[:password].present?
        save_record(account)
      end

      def destroy(id:, actor: nil)
        result = find(id: id)
        return result if result.failure?

        record = result.record
        return ServiceResult.failure(record: record, errors: { base: [I18n.t("brawo.users.errors.cannot_delete_self")] }) if
          actor&.id == record.id

        return ServiceResult.failure(record: record, errors: { base: [I18n.t("brawo.users.errors.last_super_admin")] }) if
          last_super_admin?(record)

        record.destroy
        ServiceResult.success
      end

      def build_attributes(params:, wrap_key: :user)
        raw = params[wrap_key]
        return {} if raw.blank?

        hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
        hash.symbolize_keys.slice(*ATTRIBUTE_KEYS)
      end

      def build_profile_attributes(params:, wrap_key: :profile)
        raw = params[wrap_key]
        return {} if raw.blank?

        hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
        hash.symbolize_keys.slice(*PROFILE_ATTRIBUTE_KEYS)
      end

      private

      def account_attributes(attributes)
        attrs = attributes.slice(:email, :role, :status).compact
        attrs[:status] = attrs[:status].to_sym if attrs[:status].present?
        attrs[:role] = attrs[:role].to_sym if attrs[:role].present?
        attrs[:status] ||= :verified
        attrs
      end

      def profile_attributes(attributes)
        attributes.slice(:email)
      end

      def apply_password(record, password)
        return if password.blank?

        record.password_hash = BCrypt::Password.create(password)
      end

      def save_record(record)
        if record.save
          ServiceResult.success(record)
        else
          ServiceResult.failure(record: record, errors: record.errors.to_hash)
        end
      end

      def last_super_admin?(record)
        record.super_admin? && Account.super_admin.count <= 1
      end

      def would_remove_last_super_admin?(record, attributes, actor)
        return false unless record.super_admin?

        new_role = attributes[:role].presence&.to_sym || record.role.to_sym
        return false if new_role == :super_admin

        last_super_admin?(record)
      end
    end
  end
end
