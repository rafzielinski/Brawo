require "rails_helper"

RSpec.describe BrawoCms::SlugGenerator do
  describe ".generate" do
    it "allows the same slug on different content types" do
      Page.create!(title: "About", slug: "about", status: "draft", fields: {})
      result = described_class.generate("about", record_class: Article)

      expect(result.slug).to eq("about")
      expect(result.adjusted).to be(false)
    end

    it "suffixes when the same type already uses the slug" do
      Article.create!(title: "First", slug: "hello", status: "draft", fields: {})
      result = described_class.generate("hello", record_class: Article)

      expect(result.slug).to eq("hello-2")
      expect(result.adjusted).to be(true)
    end

    it "suffixes reserved slugs for root content types" do
      result = described_class.generate("admin", record_class: Page)

      expect(result.slug).to eq("admin-2")
      expect(result.adjusted).to be(true)
    end

    it "reports a conflict without adjusting when adjust is false" do
      Article.create!(title: "First", slug: "hello", status: "draft", fields: {})
      result = described_class.generate("hello", record_class: Article, adjust: false)

      expect(result.slug).to eq("hello")
      expect(result.conflict?).to be(true)
      expect(result.suggested_slug).to eq("hello-2")
    end

    it "does not report a conflict for a free slug when adjust is false" do
      result = described_class.generate("unique-slug", record_class: Article, adjust: false)

      expect(result.slug).to eq("unique-slug")
      expect(result.conflict?).to be(false)
    end

    it "does not reserve slugs for non-root content types" do
      result = described_class.generate("articles", record_class: Article)

      expect(result.slug).to eq("articles")
      expect(result.adjusted).to be(false)
    end
  end
end
