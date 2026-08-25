module BrawoCms
  module Admin
    module ApplicationHelper
      include FieldWrapperHelper
      include FieldsHelper
      include ToggleHelper
      def brawo_format_date(date)
        date.strftime(t('brawo.formats.date'))
      end

      def brawo_format_datetime(datetime)
        datetime.strftime(t('brawo.formats.datetime'))
      end

      def brawo_status_label(status)
        t("brawo.status.#{status}", default: status.to_s.titleize)
      end

      def brawo_status_options
        %w[draft published archived].map do |status|
          [brawo_status_label(status), status]
        end
      end

      def status_badge_class(status)
        "brawo-status brawo-status--#{status.to_s.parameterize}"
      end

      def sidebar_link_class(active)
        active ? 'nav-link active' : 'nav-link'
      end

      def dashboard_sidebar_active?
        controller_name == 'dashboard'
      end

      def content_type_sidebar_active?(name)
        controller_name == 'contents' && params[:content_type].to_s == name.to_s
      end

      def taxonomy_type_sidebar_active?(name)
        controller_name == 'taxonomies' && params[:taxonomy_type].to_s == name.to_s
      end

      def previewable_content_edit?
        controller_name == 'contents' && action_name == 'edit' && @content&.persisted?
      end

      def admin_preview_url
        return unless previewable_content_edit?

        preview_admin_content_path(@content, content_type: @content_type)
      end

      def admin_preview_available?
        admin_preview_url.present?
      end
    end
  end
end
