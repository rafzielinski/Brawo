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

      def brawo_collapsible_translations
        {
          collapse_all: t("brawo.collapsible.collapse_all"),
          expand_all: t("brawo.collapsible.expand_all")
        }
      end

      def brawo_repeater_collapse_all_btn(disabled: false)
        button_tag(t("brawo.collapsible.collapse_all"), type: "button",
          class: "btn btn-outline-secondary btn-sm repeater-collapse-all-btn",
          disabled: disabled,
          data: { action: "repeater#toggleAllRowsCollapse", repeater_target: "collapseAllBtn" })
      end
    end
  end
end
