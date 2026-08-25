module BrawoCms
  module Admin
    module IconsHelper
      def brawo_icon(name, variant: :outline, size: nil, **html_options)
        aria = html_options.delete(:aria) || {}
        aria[:hidden] = true unless aria.key?(:hidden) || aria.key?("hidden")

        tag.i(
          "",
          **html_options.merge(
            class: class_names(
              "bi",
              bootstrap_icon_class(name, variant),
              "brawo-icon",
              brawo_icon_size_class(size),
              html_options[:class]
            ),
            aria: aria
          )
        )
      end

      def brawo_drag_handle(**html_options)
        title = html_options.delete(:title)
        brawo_icon(:grip_vertical, **html_options.merge(title: title))
      end

      private

      def bootstrap_icon_class(name, variant)
        base = "bi-#{name.to_s.tr('_', '-')}"
        variant.to_sym == :fill ? "#{base}-fill" : base
      end

      def brawo_icon_size_class(size)
        return if size.blank?

        "brawo-icon--#{size}"
      end
    end
  end
end
