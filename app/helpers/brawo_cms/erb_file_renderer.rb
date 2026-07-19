module BrawoCms
  # Renders .html.erb files outside Action View load paths (block render templates).
  module ErbFileRenderer
    extend ActiveSupport::Concern

    private

    def render_erb_file(template_path, **locals)
      render(inline: File.read(template_path), type: :erb, locals: locals)
    end
  end
end
