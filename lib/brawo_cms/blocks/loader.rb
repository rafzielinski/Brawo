module BrawoCms
  module Blocks
    class Loader
      BLOCK_FILE = "block.rb"

      class << self
        def load_all!
          BrawoCms.block_types.clear

          load_paths.each do |blocks_root|
            next unless blocks_root.exist?

            blocks_root.children.select(&:directory?).sort.each do |block_dir|
              block_file = block_dir.join(BLOCK_FILE)
              next unless block_file.exist?

              load_block_directory(block_dir)
            end
          end
        end

        def load_paths
          paths = []
          paths << BrawoCms::Engine.root.join("app/blocks") if defined?(BrawoCms::Engine)
          paths << Rails.root.join("app/blocks") if defined?(Rails) && Rails.respond_to?(:root)
          paths.uniq
        end

        private

        def load_block_directory(block_dir)
          name = block_dir.basename.to_s
          definition = Definition.new(name, block_dir)

          definition.instance_eval(block_dir.join(BLOCK_FILE).read, block_dir.join(BLOCK_FILE).to_s)
          Registry.register(definition)
        rescue StandardError => e
          raise LoadError, "Failed to load block #{name} from #{block_dir}: #{e.message}", e.backtrace
        end
      end
    end
  end
end
