# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "BrawoCms API v1 - Taxonomies", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
    BrawoCms.api_token = nil
  end

  path "/admin/api/v1/taxonomies" do
    parameter name: :taxonomy_type, in: :query, type: :string, required: true,
              description: "Registered taxonomy type (e.g. category)"

    get "List taxonomies" do
      tags "Taxonomies"
      produces "application/json"

      response "200", "taxonomies found" do
        let(:taxonomy_type) { "category" }

        schema type: :array, items: { "$ref" => "#/components/schemas/taxonomy" }

        before { Category.create!(name: "API Test News", slug: ApiTestData.slug("news")) }

        run_test!
      end

      response "404", "unknown taxonomy type" do
        let(:taxonomy_type) { "unknown" }

        run_test!
      end
    end

    post "Create taxonomy" do
      tags "Taxonomies"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[taxonomy_type taxonomy],
        properties: {
          taxonomy_type: { type: :string },
          taxonomy: { "$ref" => "#/components/schemas/taxonomy_input" }
        }
      }

      response "201", "taxonomy created" do
        let(:taxonomy_type) { "category" }
        let(:payload) do
          {
            taxonomy_type: "category",
            taxonomy: {
              name: "API Test Guides",
              slug: ApiTestData.slug("guides"),
              fields: { color: "#336699" }
            }
          }
        end

        schema "$ref" => "#/components/schemas/taxonomy"

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("API Test Guides")
          expect(data["fields"]["color"]).to eq("#336699")
        end
      end
    end
  end

  path "/admin/api/v1/taxonomies/{id}" do
    parameter name: :taxonomy_type, in: :query, type: :string, required: true
    parameter name: :id, in: :path, type: :integer

    let(:record) { Category.create!(name: "API Test Guides", slug: ApiTestData.slug("guides-show"), fields: { color: "#336699" }) }
    let(:taxonomy_type) { "category" }
    let(:id) { record.id }

    get "Show taxonomy" do
      tags "Taxonomies"
      produces "application/json"

      response "200", "taxonomy found" do
        schema "$ref" => "#/components/schemas/taxonomy"

        run_test!
      end

      response "404", "taxonomy not found" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Update taxonomy" do
      tags "Taxonomies"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[taxonomy_type taxonomy],
        properties: {
          taxonomy_type: { type: :string },
          taxonomy: { "$ref" => "#/components/schemas/taxonomy_input" }
        }
      }

      response "200", "taxonomy updated" do
        let(:payload) do
          {
            taxonomy_type: "category",
            taxonomy: { name: "Updated Guides", fields: { color: "#000000" } }
          }
        end

        schema "$ref" => "#/components/schemas/taxonomy"

        run_test! do |response|
          expect(JSON.parse(response.body)["name"]).to eq("Updated Guides")
        end
      end
    end

    delete "Delete taxonomy" do
      tags "Taxonomies"

      response "204", "taxonomy deleted" do
        run_test!
      end
    end
  end
end
