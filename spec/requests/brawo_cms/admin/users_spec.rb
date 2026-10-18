# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Users", type: :request do
  describe "GET /admin/admin/users" do
    it "lists users for admins" do
      get "/admin/admin/users"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Users")
      expect(response.body).to include(BrawoCmsAuthHelpers::ADMIN_EMAIL)
    end

    it "denies access to editors", skip_sign_in: true do
      editor = create_admin_account!(email: "editor@example.com", role: :editor)
      sign_in_admin(email: editor.email, role: :editor)

      get "/admin/admin/users"

      expect(response).to redirect_to("/admin/admin")
      follow_redirect!
      expect(response.body).to include("do not have permission")
    end
  end

  describe "POST /admin/admin/users" do
    it "creates a user" do
      post "/admin/admin/users", params: {
        user: {
          email: "newuser@example.com",
          role: "editor",
          status: "verified",
          password: "password123"
        }
      }

      expect(response).to redirect_to("/admin/admin/users")
      expect(BrawoCms::Account.find_by(email: "newuser@example.com")).to be_present
    end
  end
end
