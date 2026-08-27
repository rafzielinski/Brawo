# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::MediaPickerHelper, type: :helper do
  describe "#brawo_media_picker" do
    it "renders stimulus markup, modal, hidden input, and accept data" do
      html = helper.brawo_media_picker(name: "product[featured_image]", value: "7", accept: "image/*")

      expect(html).to include("data-controller=\"media-picker\"")
      expect(html).to include("name=\"product[featured_image]\"")
      expect(html).to include("data-media-picker-target=\"grid\"")
      expect(html).to include("data-media-picker-accept-value=\"image/*\"")
      expect(html).to include("data-action=\"media-picker#clearMedia\"")
      expect(html).to include("brawo-media-picker__remove")
    end
  end

  describe "#brawo_media_display" do
    it "renders empty placeholder when blank" do
      html = helper.brawo_media_display(nil)

      expect(html).to include("text-muted")
    end
  end
end
