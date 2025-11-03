# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::ContentType, type: :model do
  describe "validations" do
    it "requires a name" do
      content_type = BrawoCms::ContentType.new
      expect(content_type).not_to be_valid
      expect(content_type.errors[:name]).to be_present
    end

    it "requires a unique name" do
      BrawoCms::ContentType.create!(name: "Post", slug: "post")
      duplicate = BrawoCms::ContentType.new(name: "Post", slug: "post-2")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to be_present
    end

    it "auto-generates slug from name" do
      content_type = BrawoCms::ContentType.create!(name: "Blog Post")
      expect(content_type.slug).to eq("blog-post")
    end
  end

  describe ".register" do
    it "creates a new content type" do
      content_type = BrawoCms::ContentType.register(:post, {
        fields: [
          { name: "excerpt", type: "textarea" },
          { name: "author", type: "text" }
        ]
      })

      expect(content_type).to be_persisted
      expect(content_type.name).to eq("post")
      expect(content_type.field_definitions.count).to eq(2)
    end

    it "updates existing content type" do
      existing = BrawoCms::ContentType.create!(name: "post", slug: "post")
      updated = BrawoCms::ContentType.register(:post, {
        fields: [{ name: "title", type: "text" }]
      })

      expect(updated.id).to eq(existing.id)
      expect(updated.field_definitions.count).to eq(1)
    end
  end
end

