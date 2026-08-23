require "rails_helper"

RSpec.describe BrawoCms::SlugResolver do
  describe ".find" do
    it "returns published root-path content by slug" do
      page = Page.create!(title: "About", slug: "about-us", status: "published", fields: {})

      expect(described_class.find("about-us")).to eq(page)
    end

    it "does not return draft content" do
      Page.create!(title: "Draft", slug: "draft-page", status: "draft", fields: {})

      expect(described_class.find("draft-page")).to be_nil
    end

    it "does not return non-root content types" do
      Article.create!(title: "Post", slug: "shared-slug", status: "published", fields: {})

      expect(described_class.find("shared-slug")).to be_nil
    end
  end
end
