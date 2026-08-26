# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Fields::ColorField do
  let(:record) do
    instance_double(BrawoCms::Content, get_field: "#48BB78")
  end

  let(:field) do
    BrawoCms::FieldFactory.build(
      name: :accent_color,
      type: :color,
      label: "Accent color"
    )
  end

  describe "#display_value" do
    it "renders a swatch and hex value" do
      html = field.display_value(record)

      expect(html).to include("brawo-color-display")
      expect(html).to include("#48BB78")
    end
  end

  describe "factory registration" do
    it "builds a ColorField" do
      expect(field).to be_a(BrawoCms::Fields::ColorField)
    end
  end
end
