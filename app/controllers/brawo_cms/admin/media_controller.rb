module BrawoCms
  module Admin
    class MediaController < BaseController
      before_action :set_media, only: [:show, :edit, :update, :destroy]

      def index
        result = ::BrawoCms::MediaService.list(accept: params[:accept], q: params[:q])
        @media_items = result.records
        @media = BrawoCms::Media.new
      end

      def show
      end

      def edit
      end

      def create
        result = ::BrawoCms::MediaService.create(attributes: media_params)

        if result.success?
          redirect_to admin_medium_path(result.record),
                      notice: t("brawo.media.flash.created")
        else
          @media = result.record
          @media_items = ::BrawoCms::MediaService.list.records
          render :index, status: :unprocessable_content
        end
      end

      def update
        result = ::BrawoCms::MediaService.update(id: params[:id], attributes: media_params)

        if result.success?
          redirect_to edit_admin_medium_path(result.record),
                      notice: t("brawo.media.flash.updated")
        else
          @media = result.record
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        ::BrawoCms::MediaService.destroy(id: params[:id])
        redirect_to admin_media_path, notice: t("brawo.media.flash.deleted")
      end

      private

      def set_media
        result = ::BrawoCms::MediaService.find(id: params[:id])

        if result.success?
          @media = result.record
        else
          redirect_to admin_media_path, alert: t("brawo.errors.media_not_found")
        end
      end

      def media_params
        ::BrawoCms::MediaService.build_attributes(params: params, wrap_key: :media)
      end
    end
  end
end
