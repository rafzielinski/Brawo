# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "BrawoCms API v1 - Media", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
    BrawoCms.api_token = nil
  end

  def create_media!(title: "Test", filename: "test.png", content_type: "image/png", body: "image-data")
    media = BrawoCms::Media.new(title: title)
    media.file.attach(io: StringIO.new(body), filename: filename, content_type: content_type)
    media.save!
    media
  end

  path "/admin/api/v1/media" do
    get "List media" do
      tags "Media"
      produces "application/json"
      parameter name: :accept, in: :query, type: :string, required: false,
                description: "MIME filter (e.g. image/*)"
      parameter name: :q, in: :query, type: :string, required: false,
                description: "Search title or filename"

      response "200", "media found" do
        schema type: :array, items: { "$ref" => "#/components/schemas/media" }

        before { create_media! }

        run_test!
      end
    end

    post "Create media" do
      tags "Media"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          media: { "$ref" => "#/components/schemas/media_input" }
        }
      }

      response "201", "media created" do
        let(:blob) do
          ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new("api-upload"),
            filename: "api.png",
            content_type: "image/png"
          )
        end
        let(:payload) { { media: { title: "API upload", signed_id: blob.signed_id } } }

        schema "$ref" => "#/components/schemas/media"

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("API upload")
          expect(data["filename"]).to eq("api.png")
          expect(data["url"]).to be_present
        end
      end
    end
  end

  path "/admin/api/v1/media/{id}" do
    parameter name: :id, in: :path, type: :integer

    let(:record) { create_media! }
    let(:id) { record.id }

    get "Show media" do
      tags "Media"
      produces "application/json"

      response "200", "media found" do
        schema "$ref" => "#/components/schemas/media"

        run_test!
      end
    end

    patch "Update media" do
      tags "Media"
      consumes "application/json"
      produces "application/json"
      parameter name: :payload, in: :body, schema: {
        type: :object,
        properties: {
          media: { "$ref" => "#/components/schemas/media_input" }
        }
      }

      response "200", "media updated" do
        let(:payload) { { media: { title: "Updated title", alt_text: "Alt" } } }

        schema "$ref" => "#/components/schemas/media"

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("Updated title")
          expect(data["alt_text"]).to eq("Alt")
        end
      end
    end

    delete "Delete media" do
      tags "Media"
      produces "application/json"

      response "204", "media deleted" do
        run_test!
      end
    end
  end
end
