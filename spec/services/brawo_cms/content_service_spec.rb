# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::ContentService, type: :model do
  before do
    Rails.application.reloader.execute if Rails.application.config.cache_classes == false
  end

  describe ".create" do
    it "creates content for a registered type" do
      result = described_class.create(
        type: :article,
        attributes: { "title" => "API Article", "slug" => "api-article", "status" => "draft", "fields" => {} }
      )

      expect(result).to be_success
      expect(result.record.title).to eq("API Article")
    end

    it "returns failure for unknown type" do
      result = described_class.create(type: :unknown, attributes: { "title" => "x" })

      expect(result).to be_failure
      expect(result.error_code).to eq(:not_found)
    end

    it "returns validation errors" do
      result = described_class.create(type: :article, attributes: { "title" => "", "slug" => "" })

      expect(result).to be_failure
      expect(result.errors).to include(:title)
    end
  end

  describe ".list" do
    it "returns records for a registered type" do
      described_class.create(
        type: :article,
        attributes: { "title" => "Listed", "slug" => "listed", "status" => "draft", "fields" => {} }
      )

      result = described_class.list(type: :article)

      expect(result).to be_success
      expect(result.records.map(&:slug)).to include("listed")
    end
  end
end
