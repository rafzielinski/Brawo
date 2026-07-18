module BrawoCms
  module Blocks
    class Registry
      class << self
        def register(definition)
          BrawoCms.block_types[definition.name] = definition.to_registry_entry
        end

        def register_from_options(name, options = {})
          entry = {
            label: options[:label] || name.to_s.humanize,
            fields: options[:fields] || [],
            root_path: options[:root_path],
            render_template: options[:render_template],
            admin_template: options[:admin_template],
            stylesheet: options[:stylesheet],
            partial: options[:partial] || name.to_s
          }
          BrawoCms.block_types[name.to_sym] = entry
        end
      end
    end
  end
end
