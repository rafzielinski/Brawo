# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Authorization", type: :request, skip_sign_in: true do
  describe "viewer role" do
    before do
      create_admin_account!(email: "viewer@example.com", role: :viewer)
      sign_in_admin(email: "viewer@example.com", role: :viewer)
    end

    it "allows dashboard access" do
      get "/admin/admin"

      expect(response).to have_http_status(:ok)
    end

    it "denies media access" do
      get "/admin/admin/media"

      expect(response).to redirect_to("/admin/admin")
    end
  end
end
