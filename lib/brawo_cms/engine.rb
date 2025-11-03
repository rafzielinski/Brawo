module BrawoCms
  class Engine < ::Rails::Engine
    isolate_namespace BrawoCms

    config.generators do |g|
      g.test_framework :test_unit
      g.template_engine :erb
    end

    initializer "brawo_cms.assets" do |app|
      app.config.assets.paths << root.join("app/assets/stylesheets")
      app.config.assets.paths << root.join("app/assets/javascripts")
      app.config.assets.precompile += %w[brawo_cms/admin.css]
    end
  end
end

