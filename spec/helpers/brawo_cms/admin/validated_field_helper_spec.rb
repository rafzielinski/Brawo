# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::ValidatedFieldHelper, type: :helper do
  describe "#brawo_url_field" do
    it "renders scheme prefix and validated-field controller" do
      html = helper.brawo_url_field(name: "product[product_url]", value: "https://example.com/path")

      expect(html).to include("data-controller=\"validated-field\"")
      expect(html).to include("data-validated-field-kind-value=\"url\"")
      expect(html).to include("https://")
      expect(html).to include("example.com/path")
      expect(html).to include("name=\"product[product_url]\"")
      expect(html).to include("type=\"hidden\"")
    end

    it "splits stored URL into prefix and body" do
      html = helper.brawo_url_field(name: "product[product_url]", value: "ftp://files.example.com")

      expect(html).to include("ftp://")
      expect(html).to include("value=\"files.example.com\"")
      expect(html).to include("value=\"ftp://files.example.com\"")
    end
  end

  describe "#brawo_email_field" do
    it "renders email input with validated-field controller" do
      html = helper.brawo_email_field(name: "product[contact_email]", value: "hello@example.com")

      expect(html).to include("data-controller=\"validated-field\"")
      expect(html).to include("data-validated-field-kind-value=\"email\"")
      expect(html).to include("type=\"email\"")
      expect(html).to include("hello@example.com")
    end
  end
end
