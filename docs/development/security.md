# Security

## API

- Bearer token via `BrawoCms.api_token`. Configure in host app initializer or credentials.
- Set a strong token in production; never commit secrets.
- API controllers enforce token auth on mutating/list endpoints as implemented in `Api::V1::BaseController`.
- Full API auth and endpoint details: Swagger UI at `/admin/api/docs`.

## Admin UI

- Admin routes require a signed-in `BrawoCms::Account` with **mandatory TOTP 2FA** (Rodauth).
- Login: `/admin/login` (email/password). OAuth optional: Google, GitHub when configured.
- No self-registration — provision accounts via `rails brawo_cms:admin:create[email,password]` or seeds.
- OAuth only links to existing accounts (`omniauth_create_account? false`).
- CSRF protection on admin forms (`csrf_meta_tags` in admin layout).

### Bootstrap first admin

```bash
rails db:migrate
rails brawo_cms:admin:create[you@example.com,changeme]
```

First sign-in forces TOTP setup at `/admin/otp-setup`, then recovery codes.

### OAuth (optional)

In host `config/initializers/brawo_cms.rb`:

```ruby
BrawoCms.configure do |config|
  config.omniauth_google_client_id = ENV["GOOGLE_CLIENT_ID"]
  config.omniauth_google_client_secret = ENV["GOOGLE_CLIENT_SECRET"]
  config.omniauth_github_client_id = ENV["GITHUB_CLIENT_ID"]
  config.omniauth_github_client_secret = ENV["GITHUB_CLIENT_SECRET"]
end
```

Register redirect URIs with each provider:

- `https://yourapp.com/admin/auth/google/callback`
- `https://yourapp.com/admin/auth/github/callback`

If the engine is mounted at a path other than `/admin`, set `BrawoCms.admin_path` to match before boot.

## Host app

- Load models in `to_prepare` so content types register without eager-load leaks (see [../index.md](../index.md) setup).
- Keep `master.key` and credentials out of version control (see root `.gitignore`).

## Dependencies

- Admin loads Bootstrap 5 from jsDelivr CDN in the engine layout — consider pinning or self-hosting for strict CSP environments.
