# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "BrawoCms API v1 - Content Types", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
    BrawoCms.api_token = nil
  end

  path "/admin/api/v1/content_types" do
    get "List content types" do
      tags "Content Types"
      produces "application/json"

      response "200", "content types found" do
        schema type: :array, items: { "$ref" => "#/components/schemas/type_schema" }

        run_test! do |response|
          types = JSON.parse(response.body)
          expect(types.map { |t| t["type"] }).to include("article")
        end
      end
    end
  end

  path "/admin/api/v1/content_types/{type}" do
    parameter name: :type, in: :path, type: :string, description: "Content type key (e.g. article)"

    get "Show content type schema" do
      tags "Content Types"
      produces "application/json"

      response "200", "content type found" do
        let(:type) { "article" }

        schema "$ref" => "#/components/schemas/type_schema"

        run_test!
      end

      response "404", "content type not found" do
        let(:type) { "nonexistent" }

        run_test!
      end
    end
  end
end
