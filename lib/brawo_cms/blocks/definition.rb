module BrawoCms
  module Blocks
    class Definition
      attr_reader :name, :root_path, :fields

      def initialize(name, root_path)
        @name = name.to_sym
        @root_path = Pathname(root_path)
        @label = name.to_s.humanize
        @fields = []
      end

      def label(value = nil)
        return @label if value.nil?

        @label = value
      end

      def field(name, **options)
        @fields << options.merge(name: name)
      end

      def render_template
        template_path("render.html.erb")
      end

      def admin_template
        template_path("admin.html.erb")
      end

      def stylesheet
        %w[style.scss style.css].each do |filename|
          path = @root_path.join(filename)
          return path.to_s if path.exist?
        end
        nil
      end

      def api_only?
        render_template.nil? && admin_template.nil?
      end

      def to_registry_entry
        {
          label: label,
          fields: fields,
          root_path: root_path.to_s,
          render_template: render_template,
          admin_template: admin_template,
          stylesheet: stylesheet,
          partial: name.to_s
        }
      end

      private

      def template_path(filename)
        path = @root_path.join(filename)
        path.exist? ? path.to_s : nil
      end
    end
  end
end
