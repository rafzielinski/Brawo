module BrawoCms
  module Admin
    module MediaPickerHelper
      MEDIA_PICKER_PARTIAL = "brawo_cms/admin/shared/media_picker"

      def brawo_media_picker(**options)
        BrawoCms::Admin::BaseController.render(
          partial: MEDIA_PICKER_PARTIAL,
          locals: build_media_picker_locals(options),
          formats: [:html]
        )
      end

      def brawo_media_image_url(media, variant: :thumb)
        return nil unless media&.file&.attached?

        variant == :original ? media.file_url : media.thumbnail_url
      end

      def brawo_media_display(media_id)
        if media_id.blank?
          return content_tag(:span, I18n.t("brawo.fields.empty_value"), class: "text-muted")
        end

        media = BrawoCms::Media.find_by(id: media_id)
        return content_tag(:span, I18n.t("brawo.fields.empty_value"), class: "text-muted") unless media&.file&.attached?

        tag.span(class: "brawo-media-display") do
          preview = if media.image?
            image_tag(brawo_media_image_url(media, variant: :thumb), class: "brawo-media-display__thumb", alt: media.alt_text)
          else
            tag.span(class: "brawo-media-card__file-icon") do
              tag.i(class: "bi bi-file-earmark", aria: { hidden: true })
            end
          end

          preview + tag.span(media.display_title, class: "brawo-media-display__name")
        end
      end

      private

      def build_media_picker_locals(options)
        name = options[:name]
        value = options[:value]
        accept = options[:accept].presence || "*/*"
        disabled = options[:disabled] || false
        input_html = (options[:input_html] || {}).deep_dup
        input_class = class_names("brawo-media-picker__input d-none", input_html.delete(:class))
        picker_id = "media_picker_#{name.to_s.gsub(/[^a-z0-9]+/i, '_')}"
        selected_media = value.present? ? BrawoCms::Media.find_by(id: value) : nil

        input_field =
          if options[:form]
            form = options[:form]
            input_options = input_html.merge(
              class: input_class,
              disabled: disabled,
              data: (input_html[:data] || {}).merge(media_picker_target: "input")
            )
            form.hidden_field(name, input_options.merge(value: value))
          else
            hidden_field_tag(
              name,
              value,
              input_html.merge(
                class: input_class,
                disabled: disabled,
                data: { media_picker_target: "input" }
              )
            )
          end

        {
          value: value,
          accept: accept,
          disabled: disabled,
          input_field: input_field,
          picker_id: picker_id,
          selected_media: selected_media,
          media_index_url: BrawoCms::Engine.routes.url_helpers.api_v1_media_path
        }
      end
    end
  end
end
