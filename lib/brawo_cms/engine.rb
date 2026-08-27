module BrawoCms
  class Engine < ::Rails::Engine
    isolate_namespace BrawoCms

    config.generators do |g|
      g.test_framework :rspec
      g.template_engine :erb
    end

    initializer "brawo_cms.assets" do |app|
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/assets/javascripts")
      app.config.assets.paths << root.join("app/javascript")
      app.config.assets.paths << root.join("app/assets/config")
      app.config.assets.paths << root.join("app/assets/json")
      app.config.assets.paths << root.join("vendor/assets/stylesheets")
      app.config.assets.paths << root.join("app/blocks")
      app.config.assets.precompile += %w[
        brawo_cms/admin.css
        brawo_cms_manifest.js
        brawo_cms/application.js
        brawo_cms/controllers/application.js
        brawo_cms/controllers/index.js
        brawo_cms/controllers/page_builder_controller.js
        brawo_cms/controllers/admin_side_panel_controller.js
        brawo_cms/controllers/page_builder_side_panel_controller.js
        brawo_cms/controllers/sortable_controller.js
        brawo_cms/controllers/repeater_controller.js
        brawo_cms/controllers/color_picker_controller.js
        brawo_cms/controllers/icon_picker_controller.js
        brawo_cms/controllers/validated_field_controller.js
        brawo_cms/controllers/media_picker_controller.js
        brawo_cms/controllers/media_upload_controller.js
        brawo_cms/media_upload.js
        brawo_cms/bootstrap_icons.json
      ]
    end

    initializer "brawo_cms.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      app.config.importmap.cache_sweepers << root.join("app/javascript")
    end

    initializer "brawo_cms.host_blocks_assets" do |app|
      app.config.assets.paths << Rails.root.join("app/blocks") if Rails.root.join("app/blocks").exist?
    end

    initializer "brawo_cms.blocks" do
      config.to_prepare { BrawoCms::Blocks.load! }
    end

    initializer "brawo_cms.helpers" do
      ActiveSupport.on_load(:action_controller_base) do
        helper BrawoCms::BlocksHelper
      end
    end
  end
end

