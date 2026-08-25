module BrawoCms
  module Admin
    module ContentsHelper
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
