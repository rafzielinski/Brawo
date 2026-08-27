# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Taxonomies", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  describe "GET /admin/taxonomies" do
    it "lists taxonomies for a registered type" do
      get "/admin/admin/taxonomies", params: { taxonomy_type: "category" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Category")
    end

    it "redirects when taxonomy type is unknown" do
      get "/admin/admin/taxonomies", params: { taxonomy_type: "unknown" }

      expect(response).to redirect_to("/admin/admin")
    end
  end

  describe "PATCH /admin/taxonomies/:id" do
    let!(:category) { Category.create!(name: "Saved Category", slug: "saved-category") }

    it "redirects back to edit with a notice" do
      patch "/admin/admin/taxonomies/#{category.id}",
            params: { taxonomy_type: "category", taxonomy: { name: "Updated Category", slug: "saved-category" } }

      expect(response).to redirect_to(%r{/admin/admin/taxonomies/saved-category/edit\?taxonomy_type=category})
      follow_redirect!
      expect(response.body).to include(I18n.t("brawo.taxonomies.flash.updated", label: "Category"))
    end

    it "re-renders edit when validation fails" do
      patch "/admin/admin/taxonomies/#{category.id}",
            params: { taxonomy_type: "category", taxonomy: { name: "", slug: "saved-category" } }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "POST /admin/taxonomies" do
    it "re-renders new when validation fails" do
      post "/admin/admin/taxonomies", params: {
        taxonomy_type: "category",
        taxonomy: { name: "", slug: "" }
      }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
