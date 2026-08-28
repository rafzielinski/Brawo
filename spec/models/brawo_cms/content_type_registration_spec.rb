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
end
