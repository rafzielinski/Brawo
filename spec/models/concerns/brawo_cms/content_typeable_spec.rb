# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::ContentTypeable, type: :concern do
  # Create a test model that uses the concern
  let(:test_model_class) do
    Class.new(ActiveRecord::Base) do
      self.table_name = "posts"
      include BrawoCms::ContentTypeable

      content_type :post, {
        fields: [
          { name: "excerpt", type: "textarea" },
          { name: "author", type: "text", required: true }
        ],
        model_class_name: "Post"
      }
    end
  end

  describe "when included" do
    before do
      # Create a temporary table for testing
      ActiveRecord::Base.connection.create_table :posts, force: true do |t|
        t.string :title
        t.timestamps
      end
    end

    after do
      ActiveRecord::Base.connection.drop_table :posts if ActiveRecord::Base.connection.table_exists?(:posts)
    end

    it "provides cms_content association" do
      post = test_model_class.create!(title: "Test Post")
      expect(post).to respond_to(:cms_content)
    end

    it "allows setting CMS fields" do
      post = test_model_class.create!(title: "Test Post")
      post.set_cms_field("excerpt", "This is an excerpt")
      expect(post.cms_field("excerpt")).to eq("This is an excerpt")
    end

    it "provides cms_title accessor" do
      post = test_model_class.create!(title: "Test Post")
      expect(post).to respond_to(:cms_title)
    end
  end
end

