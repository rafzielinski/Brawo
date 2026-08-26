# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Fields::IconField do
  let(:record) do
    instance_double(BrawoCms::Content, get_field: "pencil")
  end

  let(:field) do
    BrawoCms::FieldFactory.build(
      name: :badge_icon,
      type: :icon,
      label: "Badge icon"
    )
  end

  describe "#display_value" do
    it "renders the icon and name" do
      html = field.display_value(record)

      expect(html).to include("brawo-icon-display")
      expect(html).to include("bi-pencil")
      expect(html).to include("pencil")
    end
  end

  describe "factory registration" do
    it "builds an IconField" do
      expect(field).to be_a(BrawoCms::Fields::IconField)
    end
  end
end
