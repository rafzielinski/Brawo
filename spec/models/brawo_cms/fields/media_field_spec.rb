# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Fields::MediaField do
  let(:field) do
    BrawoCms::FieldFactory.build(
      name: :hero,
      type: :media,
      label: "Hero",
      accept: "image/*"
    )
  end

  let(:record) do
  Article.new(title: "Test", slug: "test", status: "draft", fields: { "hero" => 42 })
  end

  describe "#display_value" do
    it "renders empty placeholder when value is blank" do
      record.set_field(:hero, nil)
      expect(field.display_value(record)).to include("text-muted")
    end
  end
end
