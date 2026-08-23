# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Content, type: :model do
  describe "validations" do
    it "requires a title" do
      article = Article.new(title: nil, slug: "test-slug", status: "draft")
      expect(article).not_to be_valid
      expect(article.errors[:title]).to be_present
    end

    it "requires a slug when title cannot generate one" do
      article = Article.new(title: "", slug: "", status: "draft")
      expect(article).not_to be_valid
      expect(article.errors[:slug]).to be_present
    end

    it "requires a valid status" do
      article = Article.new(title: "Test", slug: "test", status: "invalid")
      expect(article).not_to be_valid
      expect(article.errors[:status]).to be_present
    end
  end

  describe "field management" do
    let(:article) { Article.create!(title: "Test Post", slug: "test-post", status: "draft") }

    it "sets and gets fields via JSONB" do
      article.set_field("author", "Jane Doe")
      article.save!

      expect(article.get_field("author")).to eq("Jane Doe")
      expect(article.field_value("author")).to eq("Jane Doe")
    end

    it "exposes DSL-defined accessors" do
      article.author = "Bob"
      article.save!

      expect(article.author).to eq("Bob")
    end
  end

  describe "slug generation" do
    it "parameterizes title when slug is blank" do
      article = Article.new(title: "Hello World", status: "draft")
      article.valid?

      expect(article.slug).to eq("hello-world")
    end

    it "allows the same slug on different content types" do
      Page.create!(title: "About", slug: "about", status: "draft", fields: {})
      article = Article.new(title: "About", slug: "about", status: "draft")

      expect(article).to be_valid
    end
  end

  describe "scopes" do
    let!(:published_article) do
      Article.create!(title: "Published", slug: "published-article", status: "published")
    end

    let!(:draft_article) do
      Article.create!(title: "Draft", slug: "draft-article", status: "draft")
    end

    it "filters published content" do
      expect(Article.published).to include(published_article)
      expect(Article.published).not_to include(draft_article)
    end

    it "filters draft content" do
      expect(Article.draft).to include(draft_article)
      expect(Article.draft).not_to include(published_article)
    end

    it "scopes STI subclasses to their type" do
      product = Product.create!(title: "Widget", slug: "widget", status: "draft")

      expect(Article.all).to include(published_article, draft_article)
      expect(Article.all).not_to include(product)
    end
  end

  describe "content type metadata" do
    let(:article) { Article.create!(title: "Meta", slug: "meta", status: "draft") }

    it "resolves config from the registry" do
      expect(article.content_type_name).to eq("article")
      expect(article.content_type_config[:label]).to eq("Article")
      expect(article.field_definitions.map { |f| f[:name] }).to include(:author, :body)
    end
  end
end
