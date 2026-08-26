# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::IconPickerHelper, type: :helper do
  describe "#brawo_icon_picker" do
    it "renders stimulus markup, modal, and input name" do
      html = helper.brawo_icon_picker(name: "product[badge_icon]", value: "pencil")

      expect(html).to include("data-controller=\"icon-picker\"")
      expect(html).to include("name=\"product[badge_icon]\"")
      expect(html).to include("data-icon-picker-target=\"grid\"")
      expect(html).to include("bi-pencil")
    end
  end

  describe "#brawo_icon_display" do
    it "renders icon and name for a value" do
      html = helper.brawo_icon_display("pencil")

      expect(html).to include("bi-pencil")
      expect(html).to include("pencil")
    end

    it "renders empty placeholder when blank" do
      html = helper.brawo_icon_display(nil)

      expect(html).to include("text-muted")
    end
  end
end
