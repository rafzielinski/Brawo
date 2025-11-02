module Brawo
  class Engine < ::Rails::Engine
    isolate_namespace Brawo

    initializer "brawo.load_content_types" do
      # Auto-load all content types from app/content_types
      Dir[Rails.root.join('app/content_types/**/*_type.rb')].each do |file|
        require file
      end
    end

    initializer "brawo.register_content_types" do
      # Register each content type and trigger table/route generation
      Brawo::ContentType.descendants.each do |content_type_class|
        Brawo::Registry.register(content_type_class)
      end
    end
  end
end