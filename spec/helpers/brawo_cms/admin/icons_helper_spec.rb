# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::IconsHelper, type: :helper do
  describe "#brawo_icon" do
    it "renders an outline Bootstrap Icon by default" do
      html = helper.brawo_icon(:pencil)

      expect(html).to include('class="bi bi-pencil brawo-icon"')
      expect(html).to include('aria-hidden="true"')
    end

    it "renders a filled variant when requested" do
      html = helper.brawo_icon(:pencil, variant: :fill)

      expect(html).to include('class="bi bi-pencil-fill brawo-icon"')
    end

    it "applies size modifiers" do
      html = helper.brawo_icon(:eye, size: :sm)

      expect(html).to include("brawo-icon--sm")
    end
  end

  describe "#brawo_drag_handle" do
    it "renders a grip-vertical icon" do
      html = helper.brawo_drag_handle

      expect(html).to include('class="bi bi-grip-vertical brawo-icon"')
    end
  end
end
