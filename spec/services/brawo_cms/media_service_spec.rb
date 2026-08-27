# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::MediaService do
  def attach_file(media, name: "test.png", content_type: "image/png", body: "fake-image")
    media.file.attach(
      io: StringIO.new(body),
      filename: name,
      content_type: content_type
    )
  end

  describe ".create" do
    it "creates media with an attached file" do
      file = Rack::Test::UploadedFile.new(StringIO.new("image-bytes"), "image/png", original_filename: "hero.png")

      result = BrawoCms::MediaService.create(
        attributes: { title: "Hero", file: file }
      )

      expect(result).to be_success
      expect(result.record.title).to eq("Hero")
      expect(result.record.file).to be_attached
      expect(result.record.filename).to eq("hero.png")
    end

    it "creates media from a signed blob id" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("signed-image"),
        filename: "signed.png",
        content_type: "image/png"
      )

      result = BrawoCms::MediaService.create(attributes: { signed_id: blob.signed_id })

      expect(result).to be_success
      expect(result.record.filename).to eq("signed.png")
    end
  end

  describe ".list" do
    it "filters by accept mime pattern" do
      image = BrawoCms::Media.new(title: "Image")
      attach_file(image)
      image.save!

      pdf = BrawoCms::Media.new(title: "PDF")
      pdf.file.attach(
        io: StringIO.new("%PDF"),
        filename: "doc.pdf",
        content_type: "application/pdf"
      )
      pdf.save!

      result = BrawoCms::MediaService.list(accept: "image/*")

      expect(result.records).to contain_exactly(image)
    end
  end

  describe ".destroy" do
    it "removes media" do
      media = BrawoCms::Media.new
      attach_file(media)
      media.save!

      result = BrawoCms::MediaService.destroy(id: media.id)

      expect(result).to be_success
      expect(BrawoCms::Media.find_by(id: media.id)).to be_nil
    end
  end
end
