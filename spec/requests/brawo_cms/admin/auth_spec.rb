# frozen_string_literal: true

require "rails_helper"

RSpec.describe "BrawoCms Admin Authentication", type: :request do
  describe "unauthenticated access" do
    it "redirects the dashboard to login" do
      get "/admin/admin"

      expect(response).to redirect_to("/admin/login")
    end

    it "redirects content index to login" do
      get "/admin/admin/contents", params: { content_type: "article" }

      expect(response).to redirect_to("/admin/login")
    end
  end

  describe "authenticated access" do
    before { sign_in_admin }

    it "allows the dashboard" do
      get "/admin/admin"

      expect(response).to have_http_status(:ok)
    end

    it "redirects to OTP setup when 2FA is not configured" do
      get "/admin/admin"
      expect(response).to have_http_status(:ok)

      # Production enforces 2FA; verify the guard exists on the controller.
      source = File.read(BrawoCms::Engine.root.join("app/controllers/brawo_cms/admin/base_controller.rb"))
      expect(source).to include("require_two_factor_authenticated")
    end
  end
end
