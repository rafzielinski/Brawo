# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms content type registration", type: :model do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  it "registers dummy content types on load" do
    expect(BrawoCms.content_types[:article]).to be_present
    expect(BrawoCms.content_types[:article][:class]).to eq(Article)
    expect(BrawoCms.content_types[:product][:class]).to eq(Product)
  end

  it "stores field definitions on the registry entry" do
    fields = BrawoCms.content_types[:article][:fields]
    names = fields.map { |f| f[:name] }

    expect(names).to include(:author, :body, :faq_items)
  end

  it "records page_builder flag when set" do
    expect(BrawoCms.content_types[:page][:page_builder]).to be true
  end

  it "stores header_fields on the registry entry" do
    expect(BrawoCms.content_types[:article][:header_fields]).to eq([])
  end

  it "stores tabs on the registry entry" do
    article_tabs = BrawoCms.content_types[:article][:tabs].map { |tab| tab[:key] }

    expect(article_tabs).to eq(%i[content seo])
    expect(BrawoCms.content_types[:article][:fields].map { |f| f[:name] }).to include(:author, :body)
    expect(BrawoCms.content_types[:article][:show_tabs]).to be(true)
    expect(BrawoCms.content_types[:article][:seo]).to be(true)
  end

  it "omits tab chrome when only fields are configured" do
    expect(BrawoCms.content_types[:page][:show_tabs]).to be(false)
  end

  it "stores custom tabs without SEO when not requested" do
    product_tabs = BrawoCms.content_types[:product][:tabs].map { |tab| tab[:key] }

    expect(product_tabs).to eq(%i[content settings])
    expect(BrawoCms.content_types[:product][:fields].map { |f| f[:name] }).to include(:price, :sku)
    expect(BrawoCms.content_types[:product][:seo]).to be(false)
  end

  it "stores a custom content tab label" do
    content_tab = BrawoCms.content_types[:product][:tabs].find { |tab| tab[:key] == :content }

    expect(content_tab[:label]).to eq("Product Details")
  end
end
