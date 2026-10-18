# frozen_string_literal: true

module BrawoCms
  module Authorization
    ROLES = {
      viewer: 0,
      editor: 1,
      admin: 2,
      super_admin: 3
    }.freeze

    CAPABILITIES = {
      view_dashboard: %i[viewer editor admin super_admin],
      manage_content: %i[editor admin super_admin],
      manage_taxonomies: %i[editor admin super_admin],
      manage_media: %i[editor admin super_admin],
      manage_users: %i[admin super_admin]
    }.freeze

    class << self
      def capability?(role, capability)
        allowed_roles = CAPABILITIES.fetch(capability.to_sym)
        allowed_roles.include?(role.to_sym)
      end

      def roles_for_select
        ROLES.keys.map do |role|
          [I18n.t("brawo.roles.#{role}"), role]
        end
      end
    end
  end
end
