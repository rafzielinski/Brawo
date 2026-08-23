require "rails_helper"

RSpec.describe BrawoCms::Routing do
  describe ".taxonomy_route_prefix" do
    it "returns configured prefix for a taxonomy type" do
      BrawoCms.taxonomy_route_prefixes[:category] = "topics"

      expect(BrawoCms.taxonomy_route_prefix(:category)).to eq("topics")
    end

    it "falls back to pluralized type name" do
      expect(BrawoCms.taxonomy_route_prefix(:tag)).to eq("tags")
    end
  end
end
