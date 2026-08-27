module BrawoCms
  module Admin
    module CollapsibleHelper
      def brawo_collapsible_toggle(expanded: true, **html_options)
        button_tag(type: "button",
          class: class_names("brawo-icon-btn collapsible-toggle", html_options.delete(:class)),
          title: t("brawo.collapsible.toggle"),
          aria: { expanded: expanded, label: t("brawo.collapsible.toggle") },
          data: { action: "collapsible#toggle" },
          **html_options) do
          brawo_icon(:chevron_down, size: :sm)
        end
      end
    end
  end
end
