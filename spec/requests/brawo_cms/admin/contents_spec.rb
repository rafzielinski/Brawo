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

    it "shows a slug conflict modal for duplicate slugs" do
      Article.create!(title: "First", slug: "hello", status: "draft")

      post "/admin/admin/contents", params: {
        content_type: "article",
        content: { title: "Second", slug: "hello", status: "draft" }
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("slug-conflict-modal")
      expect(response.body).to include("hello-2")
      expect(response.body).to include("Go back and edit")
    end

    it "creates content with an adjusted slug when accepted" do
      Article.create!(title: "First", slug: "hello", status: "draft")

      post "/admin/admin/contents", params: {
        content_type: "article",
        accept_adjusted_slug: "1",
        content: { title: "Second", slug: "hello", status: "draft" }
      }

      expect(response).to redirect_to(%r{/admin/admin/contents/})
      expect(Article.find_by(title: "Second").slug).to eq("hello-2")
    end
  end

  describe "GET /admin/contents/:id/edit" do
    let!(:article) { Article.create!(title: "Editable Article", slug: "editable-article", status: "draft") }

    it "shows title and slug as static meta with edit controls" do
      get "/admin/admin/contents/#{article.id}/edit", params: { content_type: "article" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("content-meta")
      expect(response.body).to include("Editable Article")
      expect(response.body).to include("editable-article")
      expect(response.body).to include('data-controller="inline-edit"')
      expect(response.body).not_to include('name="content[title]" class="form-control" required="required"')
    end

    it "renders the admin mode toggle with preview enabled" do
      get "/admin/admin/contents/#{article.id}/edit", params: { content_type: "article" }

      expect(response.body).to include('data-controller="admin-mode"')
      expect(response.body).to include("/admin/admin/contents/editable-article/preview?content_type=article")
      expect(response.body).to include('data-admin-mode-target="preview"')
      expect(response.body).to include('data-admin-mode-target="loader"')
      expect(response.body).to include("brawo-toggle--segmented")
      expect(response.body).to include('data-admin-mode-target="modeToggle"')
      expect(response.body).not_to include('data-toggle-disabled-on-value="true"')
    end
  end

  describe "GET /admin/contents/:id/preview" do
    let!(:article) { Article.create!(title: "Draft Preview", slug: "draft-preview", status: "draft", fields: { author: "Jane", body: "Hello" }) }

    it "renders draft content using the host show template" do
      get "/admin/admin/contents/#{article.id}/preview", params: { content_type: "article" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Draft Preview")
      expect(response.body).to include("Hello")
    end
  end

  describe "GET /admin/contents/new" do
    it "disables preview in the admin mode toggle" do
      get "/admin/admin/contents/new", params: { content_type: "article" }

      expect(response.body).to include('data-controller="admin-mode"')
      expect(response.body).to include('data-admin-mode-preview-url-value=""')
      expect(response.body).to include('data-toggle-on-state-value="preview"')
      expect(response.body).to include('data-toggle-disabled-on-value="true"')
    end
  end
end
