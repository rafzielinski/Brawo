# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Content, type: :model do
  let(:content_type) do
    BrawoCms::ContentType.create!(
      name: "Post",
      slug: "post",
      field_definitions: [
        { name: "excerpt", type: "textarea" },
        { name: "author", type: "text", required: true },
        { name: "views", type: "number" }
      ]
    )
  end

  describe "validations" do
    it "requires a title" do
      content = BrawoCms::Content.new(content_type: content_type)
      expect(content).not_to be_valid
      expect(content.errors[:title]).to be_present
    end

    it "requires a content_type" do
      content = BrawoCms::Content.new(title: "Test")
      expect(content).not_to be_valid
      expect(content.errors[:content_type]).to be_present
    end
  end

  describe "field management" do
    let(:content) { BrawoCms::Content.create!(content_type: content_type, title: "Test Post") }

    it "sets and gets fields" do
      content.set_field("excerpt", "This is an excerpt")
      content.set_field("views", "100")
      content.save!

      expect(content.field("excerpt")).to eq("This is an excerpt")
      expect(content.field("views")).to eq(100) # Should be coerced to integer
    end

    it "coerces field types" do
      content.set_field("views", "42")
      content.save!

      expect(content.field("views")).to be_a(Integer)
      expect(content.field("views")).to eq(42)
    end

    it "validates required fields" do
      content.fields = {}
      expect(content).not_to be_valid
      expect(content.errors[:author]).to be_present
    end
  end

  describe "publishing" do
    let(:content) { BrawoCms::Content.create!(content_type: content_type, title: "Test Post") }

    it "publishes content" do
      content.publish!
      expect(content.published).to be true
      expect(content.published_at).to be_present
    end

    it "unpublishes content" do
      content.publish!
      content.unpublish!
      expect(content.published).to be false
    end
  end

  describe "scopes" do
    let!(:published_content) do
      BrawoCms::Content.create!(
        content_type: content_type,
        title: "Published",
        published: true
      )
    end

    let!(:draft_content) do
      BrawoCms::Content.create!(
        content_type: content_type,
        title: "Draft",
        published: false
      )
    end

    it "filters published content" do
      expect(BrawoCms::Content.published).to include(published_content)
      expect(BrawoCms::Content.published).not_to include(draft_content)
    end

    it "filters draft content" do
      expect(BrawoCms::Content.draft).to include(draft_content)
      expect(BrawoCms::Content.draft).not_to include(published_content)
    end

    it "filters by content type" do
      other_type = BrawoCms::ContentType.create!(name: "Page", slug: "page")
      other_content = BrawoCms::Content.create!(content_type: other_type, title: "Other")

      expect(BrawoCms::Content.by_content_type(content_type)).to include(published_content)
      expect(BrawoCms::Content.by_content_type(content_type)).to include(draft_content)
      expect(BrawoCms::Content.by_content_type(content_type)).not_to include(other_content)
    end
  end
end

