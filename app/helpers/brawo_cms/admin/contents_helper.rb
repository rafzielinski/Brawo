module BrawoCms
  module Admin
    module ContentsHelper
      def content_type_field_tabs(config)
        config[:tabs] || []
      end

      def content_type_show_tabs?(config)
        config[:show_tabs] == true
      end

      def field_tab_label(tab)
        tab[:label].presence || I18n.t("brawo.sections.#{tab[:key]}", default: tab[:key].to_s.titleize)
      end

      def active_field_tab_key(tabs, content)
        error_keys = content.errors.attribute_names.map(&:to_s)

        tabs.each do |tab|
          field_names = (tab[:fields] || []).map { |field| field[:name].to_s }
          return tab[:key] if (error_keys & field_names).any?
        end

        tabs.first&.dig(:key)
      end

      def field_tab_has_errors?(tab, content)
        error_keys = content.errors.attribute_names.map(&:to_s)
        field_names = (tab[:fields] || []).map { |field| field[:name].to_s }
        (error_keys & field_names).any?
      end

      def content_public_path(content, content_type:)
        slug = content.slug
        return "#" if slug.blank?

        if BrawoCms.root_content_type?(content_type)
          "/#{slug}"
        else
          "/#{content_type.to_s.pluralize}/#{slug}"
        end
      end

      def content_meta_edit_button
        tag.button(
          type: "button",
          class: "content-meta__edit",
          data: { action: "inline-edit#edit" },
          aria: { label: t("brawo.actions.edit") }
        ) do
          safe_join([
            content_meta_edit_icon,
            tag.span(t("brawo.actions.edit"), class: "content-meta__edit-label")
          ])
        end
      end

      def content_meta_cancel_button
        tag.button(
          type: "button",
          class: "content-meta__edit content-meta__edit--icon-only",
          data: { action: "inline-edit#cancel" },
          aria: { label: t("brawo.actions.cancel") }
        ) do
          content_meta_cancel_icon
        end
      end

      private

      def content_meta_edit_icon
        brawo_icon(:pencil, size: :sm)
      end

      def content_meta_cancel_icon
        brawo_icon(:x_lg, size: :sm)
      end
    end
  end
end
