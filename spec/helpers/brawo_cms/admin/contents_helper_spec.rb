# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::ContentsHelper, type: :helper do
  describe "#content_public_path" do
    let(:article) { Article.create!(title: "Test", slug: "test-article", status: "draft") }

    it "returns pluralized type path for standard content types" do
      expect(helper.content_public_path(article, content_type: :article)).to eq("/articles/test-article")
    end

    it "returns root path for root content types" do
      page = Page.create!(title: "Home", slug: "home", status: "draft")

      expect(helper.content_public_path(page, content_type: :page)).to eq("/home")
    end
  end
end
