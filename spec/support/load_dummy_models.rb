# frozen_string_literal: true

Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/models/**/*.rb")].each { |file| require_dependency file }
end
