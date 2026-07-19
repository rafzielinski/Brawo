# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Contents", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  describe "GET /admin/contents" do
    it "lists content for a registered type" do
      get "/admin/admin/contents", params: { content_type: "article" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Article")
    end

    it "redirects when content type is unknown" do
      get "/admin/admin/contents", params: { content_type: "unknown" }

      expect(response).to redirect_to("/admin/admin")
    end
  end

  describe "POST /admin/contents" do
    it "re-renders new when validation fails" do
      post "/admin/admin/contents", params: {
        content_type: "article",
        content: { title: "", slug: "", status: "draft" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
