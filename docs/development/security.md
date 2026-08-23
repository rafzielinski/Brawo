# Security

## API

- Bearer token via `BrawoCms.api_token`. Configure in host app initializer or credentials.
- Set a strong token in production; never commit secrets.
- API controllers enforce token auth on mutating/list endpoints as implemented in `Api::V1::BaseController`.
- Full API auth and endpoint details: Swagger UI at `/admin/api/docs`.

## Admin UI

- Mounted as a Rails engine; uses standard **CSRF** protection (`csrf_meta_tags` in admin layout).
- **No built-in admin authentication** — anyone who can reach `/admin` can use the UI unless the host app adds authentication (e.g. route constraint, `before_action` in a host wrapper, or reverse-proxy auth).
- Treat admin mount path as sensitive in production; place behind VPN, SSO, or Devise as appropriate.

## Host app

- Load models in `to_prepare` so content types register without eager-load leaks (see [../index.md](../index.md) setup).
- Keep `master.key` and credentials out of version control (see root `.gitignore`).

## Dependencies

- Admin loads Bootstrap 5 from jsDelivr CDN in the engine layout — consider pinning or self-hosting for strict CSP environments.
