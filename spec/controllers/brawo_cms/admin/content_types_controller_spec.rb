# frozen_string_literal: true

require "rails_helper"

RSpec.describe BrawoCms::Admin::ContentTypesController, type: :controller do
  routes { BrawoCms::Engine.routes }

  describe "GET #index" do
    it "returns a successful response" do
      get :index
      expect(response).to be_successful
    end

    it "lists content types" do
      content_type = BrawoCms::ContentType.create!(
        name: "Post",
        slug: "post",
        field_definitions: []
      )

      get :index
      expect(assigns(:content_types)).to include(content_type)
    end
  end

  describe "GET #show" do
    it "returns a successful response" do
      content_type = BrawoCms::ContentType.create!(
        name: "Post",
        slug: "post",
        field_definitions: []
      )

      get :show, params: { id: content_type.id }
      expect(response).to be_successful
    end
  end

  describe "GET #new" do
    it "returns a successful response" do
      get :new
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new content type" do
        expect {
          post :create, params: {
            content_type: {
              name: "Article",
              slug: "article",
              field_definitions_text: '[{"name": "excerpt", "type": "textarea"}]'
            }
          }
        }.to change(BrawoCms::ContentType, :count).by(1)
      end

      it "redirects to the created content type" do
        post :create, params: {
          content_type: {
            name: "Article",
            slug: "article",
            field_definitions_text: '[]'
          }
        }
        expect(response).to redirect_to(brawo_cms.admin_content_type_path(BrawoCms::ContentType.last))
      end
    end

    context "with invalid params" do
      it "does not create content type" do
        expect {
          post :create, params: {
            content_type: { name: "" }
          }
        }.not_to change(BrawoCms::ContentType, :count)
      end
    end
  end
end

