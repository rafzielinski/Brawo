# Load content type models to register them with BrawoCMS
Rails.application.config.to_prepare do
  # Load all models that inherit from BrawoCms::Content
  Dir[Rails.root.join('app/models/**/*.rb')].each do |file|
    require_dependency file
  end
end

