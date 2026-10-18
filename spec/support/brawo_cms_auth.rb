# frozen_string_literal: true

require "bcrypt"

module BrawoCmsAuthHelpers
  ADMIN_EMAIL = "admin@example.com"
  ADMIN_PASSWORD = "password123"

  def create_admin_account!(email: ADMIN_EMAIL, password: ADMIN_PASSWORD, role: :super_admin)
    account = BrawoCms::Account.find_by(email: email)
    return account if account

    BrawoCms::Account.create!(
      email: email,
      status: :verified,
      role: role,
      password_hash: BCrypt::Password.create(password)
    )
  end

  def sign_in_admin(email: ADMIN_EMAIL, password: ADMIN_PASSWORD, role: :super_admin)
    account = BrawoCms::Account.find_by(email: email)
    account.update!(role: role) if account && account.role.to_sym != role
    create_admin_account!(email: email, password: password, role: role)

    post "/admin/login", params: { email: email, password: password }
    follow_redirect! while response.redirect?
  end
end

RSpec.configure do |config|
  config.include BrawoCmsAuthHelpers, type: :request

  config.before(:each, type: :request) do |example|
    next unless example.file_path.include?("/admin/")
    next if example.file_path.include?("auth_spec.rb")
    next if example.metadata[:skip_sign_in]

    sign_in_admin
  end
end
