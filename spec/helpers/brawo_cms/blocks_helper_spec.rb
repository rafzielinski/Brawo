# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::BlocksHelper, type: :helper do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  describe "#render_block" do
    it "evaluates block render templates as ERB" do
      html = helper.render_block(
        type: "heading",
        data: { text: "Hello", level: 2 }
      )

      expect(html).to include('<h2 class="mb-3">Hello</h2>')
      expect(html).not_to include("<%")
    end

    it "renders text blocks with simple_format" do
      html = helper.render_block(
        type: "text",
        data: { body: "Line one\nLine two" }
      )

      expect(html).to include("Line one")
      expect(html).to include("<br")
      expect(html).not_to include("<%")
    end
  end
end
