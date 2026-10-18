# frozen_string_literal: true

module BrawoCms
  module Admin
    class ProfilesController < BaseController
      def edit
        @profile = current_account
      end

      def update
        result = ::BrawoCms::AccountService.update_profile(
          account: current_account,
          attributes: profile_params
        )

        if result.success?
          redirect_to edit_admin_profile_path, notice: t("brawo.profile.flash.updated")
        else
          @profile = result.record
          render :edit, status: :unprocessable_content
        end
      end

      private

      def profile_params
        ::BrawoCms::AccountService.build_profile_attributes(params: params, wrap_key: :profile)
      end
    end
  end
end
