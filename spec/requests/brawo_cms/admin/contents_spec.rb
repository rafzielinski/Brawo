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
  end
end
