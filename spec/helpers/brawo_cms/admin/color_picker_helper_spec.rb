# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::ColorPickerHelper, type: :helper do
  describe "#brawo_color_picker" do
    it "renders stimulus markup and input name" do
      html = helper.brawo_color_picker(name: "product[accent_color]", value: "#48BB78")

      expect(html).to include("data-controller=\"color-picker\"")
      expect(html).to include("name=\"product[accent_color]\"")
      expect(html).to include("data-color-picker-target=\"input\"")
      expect(html).to include("data-color-picker-target=\"pickerInput\"")
      expect(html).not_to include("data-coloris")
    end
  end

  describe "#brawo_color_display" do
    it "renders swatch and hex for a value" do
      html = helper.brawo_color_display("#48BB78")

      expect(html).to include("brawo-color-display__swatch")
      expect(html).to include("#48BB78")
    end

    it "renders empty placeholder when blank" do
      html = helper.brawo_color_display(nil)

      expect(html).to include("text-muted")
    end
  end
end
