# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "BrawoCms API v1 - Contents", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
    BrawoCms.api_token = nil
  end

  path "/admin/api/v1/contents" do
    parameter name: :content_type, in: :query, type: :string, required: true,
              description: "Registered content type (e.g. article)"

    get "List contents" do
      tags "Contents"
      produces "application/json"

      response "200", "contents found" do
        let(:content_type) { "article" }

        schema type: :array, items: { "$ref" => "#/components/schemas/content" }

        before { Article.create!(title: "API Test Seed", slug: ApiTestData.slug("seed"), status: "draft") }

        run_test!
      end

      response "404", "unknown content type" do
        let(:content_type) { "unknown" }

        run_test!
      end
    end

    post "Create content" do
      tags "Contents"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[content_type content],
        properties: {
          content_type: { type: :string },
          content: { "$ref" => "#/components/schemas/content_input" }
        }
      }

      response "201", "content created" do
        let(:content_type) { "article" }
        let(:payload) do
          {
            content_type: "article",
            content: {
              title: "Hello API",
              slug: ApiTestData.slug("hello-api"),
              status: "draft",
              fields: { author: "Jane" }
            }
          }
        end

        schema "$ref" => "#/components/schemas/content"

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("Hello API")
          expect(data["fields"]["author"]).to eq("Jane")
        end
      end
    end
  end

  path "/admin/api/v1/contents/{id}" do
    parameter name: :content_type, in: :query, type: :string, required: true
    parameter name: :id, in: :path, type: :integer

    let(:record) { Article.create!(title: "Hello API", slug: ApiTestData.slug("hello-api-show"), status: "draft", fields: { author: "Jane" }) }
    let(:content_type) { "article" }
    let(:id) { record.id }

    get "Show content" do
      tags "Contents"
      produces "application/json"

      response "200", "content found" do
        schema "$ref" => "#/components/schemas/content"

        run_test!
      end

      response "404", "content not found" do
        let(:id) { 0 }

        run_test!
      end
    end

    patch "Update content" do
      tags "Contents"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        required: %w[content_type content],
        properties: {
          content_type: { type: :string },
          content: { "$ref" => "#/components/schemas/content_input" }
        }
      }

      response "200", "content updated" do
        let(:payload) do
          {
            content_type: "article",
            content: { title: "Updated API", fields: { author: "John" } }
          }
        end

        schema "$ref" => "#/components/schemas/content"

        run_test! do |response|
          expect(JSON.parse(response.body)["title"]).to eq("Updated API")
        end
      end
    end

    delete "Delete content" do
      tags "Contents"

      response "204", "content deleted" do
        run_test!
      end
    end
  end
end
