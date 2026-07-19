# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::ContentTypeable, type: :model do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  it "uses the shared contents table" do
    expect(Article.table_name).to eq("brawo_cms_contents")
  end

  it "registers the model with BrawoCms" do
    expect(BrawoCms.content_types[:article][:class]).to eq(Article)
  end

  it "defines field accessors from the DSL" do
    article = Article.create!(title: "Concern test", slug: "concern-test", status: "draft")
    article.body = "Hello"
    article.featured = true
    article.save!

    expect(article.body).to eq("Hello")
    expect(article.featured).to be true
  end

  it "default_scope limits queries to the STI type" do
    article = Article.create!(title: "Scoped", slug: "scoped-article", status: "draft")
    product = Product.create!(title: "Scoped product", slug: "scoped-product", status: "draft")

    expect(Article.find(article.id)).to eq(article)
    expect { Article.find(product.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
