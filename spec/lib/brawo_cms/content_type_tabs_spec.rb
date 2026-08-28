# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::ContentTypeTabs do
  describe ".build" do
    it "returns no tabs when tabs are not configured" do
      tabs = described_class.build(fields: [{ name: :body, type: :textarea, label: "Body" }])

      expect(tabs).to eq([])
    end

    it "builds configured tabs without folding in top-level fields" do
      tabs = described_class.build(
        fields: [{ name: :body, type: :textarea, label: "Body" }],
        tabs: [{ seo: true }]
      )

      expect(tabs.map { |tab| tab[:key] }).to eq([:seo])
    end

    it "allows a content tab entry" do
      tabs = described_class.build(
        tabs: [
          { key: :content, fields: [{ name: :body, type: :textarea, label: "Body" }] },
          { seo: true }
        ]
      )

      expect(tabs.map { |tab| tab[:key] }).to eq(%i[content seo])
      expect(described_class.content_tab_fields(tabs).map { |field| field[:name] }).to eq([:body])
    end

    it "builds tabs only from tabs config when fields are omitted" do
      tabs = described_class.build(
        tabs: [
          { key: :main, label: "Main", fields: [{ name: :body, type: :textarea, label: "Body" }] },
          { seo: true }
        ]
      )

      expect(tabs.map { |tab| tab[:key] }).to eq(%i[main seo])
    end

    it "supports custom SEO tab fields and labels" do
      tabs = described_class.build(
        tabs: [
          { seo: true, label: "Search", fields: [{ name: :meta_title, type: :string, label: "Title" }] }
        ]
      )

      expect(tabs.first[:key]).to eq(:seo)
      expect(tabs.first[:label]).to eq("Search")
      expect(tabs.first[:fields]).to eq([{ name: :meta_title, type: :string, label: "Title" }])
    end

    it "raises for reserved custom tab keys" do
      expect do
        described_class.build(tabs: [{ key: :seo, label: "SEO", fields: [] }])
      end.to raise_error(ArgumentError, /reserved/)
    end
  end

  describe ".all_fields" do
    it "combines top-level fields, tab fields, and header fields" do
      fields = described_class.all_fields(
        [{ key: :seo, fields: [{ name: :meta_title, type: :string, label: "Title" }] }],
        fields: [{ name: :body, type: :textarea, label: "Body" }],
        header_fields: [{ name: :tagline, type: :string, label: "Tagline" }]
      )

      expect(fields.map { |field| field[:name] }).to eq(%i[body meta_title tagline])
    end
  end

  describe ".show_tabs?" do
    it "is false when tabs are not configured" do
      expect(described_class.show_tabs?(fields: [{ name: :body, type: :string, label: "Body" }])).to be(false)
    end

    it "is true when tabs are configured" do
      expect(described_class.show_tabs?(tabs: [{ seo: true }])).to be(true)
    end
  end
end
