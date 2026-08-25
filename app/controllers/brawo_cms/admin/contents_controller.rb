module BrawoCms
  module Admin
    class ContentsController < BaseController
      helper BrawoCms::Admin::PageBuilderHelper

      before_action :set_content_type
      before_action :set_content, only: [:show, :edit, :update, :destroy, :preview]

      def index
        result = ::BrawoCms::ContentService.list(type: @content_type)
        @contents = result.records
      end

      def show
      end

      def new
        @content = content_class.new
      end

      def edit
      end

      def preview
        render_content_preview(@content)
      end

      def create
        result = ::BrawoCms::ContentService.create(
          type: @content_type,
          attributes: content_params,
          accept_adjusted_slug: params[:accept_adjusted_slug] == "1"
        )

        if result.success?
          redirect_to admin_content_path(result.record, content_type: params[:content_type]),
                      notice: t('brawo.contents.flash.created', label: @content_type_config[:label])
        else
          @content = result.record
          @slug_conflict = result.slug_conflict if result.slug_conflict?
          render :new, status: :unprocessable_entity
        end
      end

      def update
        result = ::BrawoCms::ContentService.update(
          type: @content_type,
          id: params[:id],
          attributes: content_params
        )

        if result.success?
          redirect_to admin_content_path(result.record, content_type: params[:content_type]),
                      notice: t('brawo.contents.flash.updated', label: @content_type_config[:label])
        else
          @content = result.record
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        ::BrawoCms::ContentService.destroy(type: @content_type, id: params[:id])
        redirect_to admin_contents_path(content_type: params[:content_type]),
                    notice: t('brawo.contents.flash.deleted', label: @content_type_config[:label])
      end

      private

      def set_content_type
        @content_type = params[:content_type]&.to_sym
        @content_type_config = ::BrawoCms::ContentService.type_config(@content_type)

        unless @content_type_config
          redirect_to admin_root_path, alert: t('brawo.errors.content_type_not_found') and return
        end
      end

      def set_content
        result = ::BrawoCms::ContentService.find(type: @content_type, id: params[:id])

        if result.success?
          @content = result.record
        else
          redirect_to admin_contents_path(content_type: params[:content_type]),
                      alert: t('brawo.errors.content_not_found')
        end
      end

      def content_class
        @content_type_config[:class]
      end

      def content_params
        ::BrawoCms::ContentService.build_attributes(
          type_config: @content_type_config,
          params: params,
          wrap_key: :content
        )
      end

      def render_content_preview(content)
        element = content.model_name.element

        template, render_options = if BrawoCms.root_content_type?(@content_type)
          [
            "slugs/show",
            { locals: { content: content, partial: element } }
          ]
        else
          [
            "#{content.model_name.plural}/show",
            { assigns: { element.to_sym => content } }
          ]
        end

        html = host_renderer.render(
          template: template,
          layout: preview_layout,
          **render_options
        )

        render html: html, layout: false
      rescue ActionView::MissingTemplate
        render template: "brawo_cms/admin/contents/preview_fallback",
               locals: { content: content },
               layout: false
      end

      def host_renderer
        @host_renderer ||= ::ApplicationController.renderer.new(
          "HTTP_HOST" => request.host_with_port,
          "HTTPS" => request.ssl? ? "on" : "off",
          "rack.url_scheme" => request.scheme
        )
      end

      def preview_layout
        "application"
      end
    end
  end
end
