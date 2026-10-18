class ApplicationController < ActionController::Base
  helper BrawoCms::BlocksHelper

  # Render the static 404 page instead of the error page when a record
  # (e.g. a draft/archived article) is not publicly available.
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  # # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  private

  def render_not_found
    render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false
  end
end

