# frozen_string_literal: true

if defined?(Rswag::Api)
  Rswag::Api.configure do |c|
    c.openapi_root = BrawoCms::Engine.root.join("openapi").to_s
  end
end
