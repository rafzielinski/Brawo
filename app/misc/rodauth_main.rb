# frozen_string_literal: true

require "sequel/core"
require "omniauth-google-oauth2"
require "omniauth-github"

class RodauthMain < Rodauth::Rails::Auth
  configure do
    enable :login, :logout, :otp, :recovery_codes, :lockout, :active_sessions, :omniauth, :internal_request

    db Sequel.postgres(extensions: :activerecord_connection, keep_reference: false)
    convert_token_id_to_integer? { BrawoCms::Account.columns_hash["id"].type == :integer }

    accounts_table :brawo_cms_accounts
    otp_keys_table :brawo_cms_account_otp_keys
    recovery_codes_table :brawo_cms_account_recovery_codes
    account_login_failures_table :brawo_cms_account_login_failures
    account_lockouts_table :brawo_cms_account_lockouts
    active_sessions_table :brawo_cms_account_active_session_keys
    active_sessions_account_id_column :brawo_cms_account_id
    omniauth_identities_table :brawo_cms_account_identities
    omniauth_identities_account_id_column :brawo_cms_account_id

    prefix BrawoCms.admin_path
    omniauth_prefix "#{BrawoCms.admin_path}/auth"
    domain { Rails.application.config.action_mailer.default_url_options&.fetch(:host, "localhost") }

    rails_controller { BrawoCms::RodauthController }
    rails_account_model { BrawoCms::Account }
    title_instance_variable :@page_title

    account_status_column :status
    account_password_hash_column :password_hash
    login_param "email"

    omniauth_create_account? false
    omniauth_two_factors? false

  if BrawoCms.omniauth_google_client_id.present? && BrawoCms.omniauth_google_client_secret.present?
    omniauth_provider :google_oauth2,
      BrawoCms.omniauth_google_client_id,
      BrawoCms.omniauth_google_client_secret,
      name: :google,
      scope: "email"
  end

  if BrawoCms.omniauth_github_client_id.present? && BrawoCms.omniauth_github_client_secret.present?
    omniauth_provider :github,
      BrawoCms.omniauth_github_client_id,
      BrawoCms.omniauth_github_client_secret,
      scope: "user:email"
  end

    login_redirect { "#{BrawoCms.admin_path}/admin" }
    logout_redirect { login_path }
    omniauth_failure_redirect { login_path }
    omniauth_login_failure_redirect { login_path }
    two_factor_need_setup_redirect { otp_setup_path }
    two_factor_auth_required_redirect do
      uses_two_factor_authentication? ? otp_auth_path : otp_setup_path
    end
    two_factor_auth_return_to_requested_location? true
    login_return_to_requested_location? true

    require_login_error_flash "You must sign in to access the admin."
    omniauth_login_no_matching_account_error_flash "No admin account exists for that identity. Contact an administrator."
    already_logged_in { redirect login_redirect }
  end
end
