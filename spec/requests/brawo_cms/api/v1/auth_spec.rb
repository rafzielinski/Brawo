# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms API v1 auth", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
    BrawoCms.api_token = "secret"
  end

  it "rejects requests without a token when configured" do
    get "/admin/api/v1/content_types"

    expect(response).to have_http_status(:unauthorized)
  end

  it "accepts requests with a valid bearer token" do
    get "/admin/api/v1/content_types", headers: { "Authorization" => "Bearer secret" }

    expect(response).to have_http_status(:ok)
  end
end
