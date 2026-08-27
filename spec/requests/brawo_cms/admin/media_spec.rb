# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Media", type: :request do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  def create_media!
    media = BrawoCms::Media.new(title: "Fixture")
    media.file.attach(
      io: StringIO.new("image-data"),
      filename: "fixture.png",
      content_type: "image/png"
    )
    media.save!
    media
  end

  describe "GET /admin/media" do
    it "lists media library with upload zone" do
      create_media!

      get "/admin/admin/media"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Media Library")
      expect(response.body).to include("data-controller=\"media-upload\"")
      expect(response.body).to include("fixture.png")
    end
  end

  describe "POST /admin/media" do
    it "creates media via multipart file upload" do
      file = Rack::Test::UploadedFile.new(StringIO.new("uploaded"), "image/png", original_filename: "upload.png")

      post "/admin/api/v1/media", params: { media: { title: "Upload", file: file } }

      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data["filename"]).to eq("upload.png")
      expect(data["url"]).to be_present
      expect(data["thumbnail_url"]).to be_present
    end
  end

  describe "DELETE /admin/media/:id" do
    it "deletes media" do
      media = create_media!

      delete "/admin/admin/media/#{media.id}"

      expect(response).to redirect_to("/admin/admin/media")
      expect(BrawoCms::Media.find_by(id: media.id)).to be_nil
    end
  end
end
