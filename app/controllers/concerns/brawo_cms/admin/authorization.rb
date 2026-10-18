# frozen_string_literal: true

module BrawoCms
  module Admin
    module Authorization
      extend ActiveSupport::Concern

      included do
        helper_method :can?
      end

      class_methods do
        def require_capability(capability, only: nil, except: nil)
          before_action(only: only, except: except) { authorize_capability!(capability) }
        end
      end

      private

      def authorize_capability!(capability)
        return if current_account&.can?(capability)

        redirect_to admin_root_path, alert: t("brawo.errors.forbidden")
      end

      def can?(capability)
        current_account&.can?(capability)
      end
    end
  end
end
