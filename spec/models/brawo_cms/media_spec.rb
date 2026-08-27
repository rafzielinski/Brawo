# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Media do
  def attach_image(media, body: "fake", filename: "test.png")
    media.file.attach(
      io: StringIO.new(body),
      filename: filename,
      content_type: "image/png"
    )
  end

  describe "#thumbnail_url" do
    it "returns a representation path for images" do
      media = BrawoCms::Media.new(title: "Hero")
      attach_image(media)
      media.save!

      expect(media.thumbnail_url).to include("/rails/active_storage/representations/")
      expect(media.thumbnail_url).not_to eq(media.file_url)
    end

    it "returns nil for non-image files" do
      media = BrawoCms::Media.new(title: "Doc")
      media.file.attach(
        io: StringIO.new("%PDF"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )
      media.save!

      expect(media.thumbnail_url).to be_nil
      expect(media.file_url).to be_present
    end
  end
end
