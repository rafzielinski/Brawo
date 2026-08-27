module BrawoCms
  module Admin
    module SidePanelHelper
      def render_admin_side_panel(id:, title:, content:, controllers: "admin-side-panel", data: {})
        BrawoCms::Admin::BaseController.render(
          partial: "brawo_cms/admin/shared/side_panel",
          locals: {
            id: id,
            title: title,
            content: content,
            controllers: controllers,
            data: data
          },
          formats: [:html]
        ).html_safe
      end
    end
  end
end
