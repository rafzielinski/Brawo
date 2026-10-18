# frozen_string_literal: true

module BrawoCms
  module Admin
    class UsersController < BaseController
      require_capability :manage_users

      before_action :set_user, only: [:show, :edit, :update, :destroy]

      def index
        result = ::BrawoCms::AccountService.list
        @users = result.records
      end

      def show
      end

      def new
        @user = BrawoCms::Account.new(status: :verified, role: :editor)
      end

      def edit
      end

      def create
        result = ::BrawoCms::AccountService.create(attributes: user_params)

        if result.success?
          redirect_to admin_users_path, notice: t("brawo.users.flash.created")
        else
          @user = result.record
          render :new, status: :unprocessable_content
        end
      end

      def update
        result = ::BrawoCms::AccountService.update(
          id: params[:id],
          attributes: user_params,
          actor: current_account
        )

        if result.success?
          redirect_to edit_admin_user_path(result.record), notice: t("brawo.users.flash.updated")
        else
          @user = result.record
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        result = ::BrawoCms::AccountService.destroy(id: params[:id], actor: current_account)

        if result.success?
          redirect_to admin_users_path, notice: t("brawo.users.flash.deleted")
        else
          redirect_to admin_users_path, alert: result.errors[:base]&.first || t("brawo.errors.forbidden")
        end
      end

      private

      def set_user
        result = ::BrawoCms::AccountService.find(id: params[:id])

        if result.success?
          @user = result.record
        else
          redirect_to admin_users_path, alert: t("brawo.errors.user_not_found")
        end
      end

      def user_params
        ::BrawoCms::AccountService.build_attributes(params: params, wrap_key: :user)
      end
    end
  end
end
