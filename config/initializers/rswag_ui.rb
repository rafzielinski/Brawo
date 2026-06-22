# frozen_string_literal: true

if defined?(Rswag::Ui)
  Rswag::Ui.configure do |c|
    # Relative to the Rswag::Api mount at /api/docs (under the engine mount prefix).
    c.openapi_endpoint "v1/swagger.yaml", "BrawoCMS API V1"
  end
end
