# Testing

## Quick start

```bash
bundle exec rspec
```

Specs boot the **dummy host app** (`test/dummy`) via `spec/rails_helper.rb`. `Rails.root` in specs points at the dummy, not the gem root.

## Layout

| Path | Purpose |
|------|---------|
| `spec/models/` | STI models, registry, concerns |
| `spec/services/` | `ContentService`, etc. |
| `spec/helpers/` | Admin helpers |
| `spec/requests/brawo_cms/api/v1/` | API + OpenAPI (rswag) |
| `spec/requests/brawo_cms/admin/` | Admin HTML smoke tests |

## Dummy app as contract

Integration types live in `test/dummy/app/models/`:

- `Article`, `Product`, `Page` (content)
- `Category` (taxonomy)

API specs use `spec/support/api_test_data.rb` for unique slugs. Extend these models when adding field types or API behavior.

## Migrations

Engine migrations live in `db/migrate/`. The dummy app keeps a copy under `test/dummy/db/migrate/` (synced by `setup.sh` or manual copy). After adding engine migrations:

```bash
cp db/migrate/*.rb test/dummy/db/migrate/
cd test/dummy && BUNDLE_GEMFILE=../../Gemfile bundle exec rails db:migrate
```

Or run `./setup.sh` if you use the Docker demo workflow.

## OpenAPI

```bash
bundle exec rake openapi:generate
```

Updates `openapi/v1/swagger.yaml` from request specs. See [api.md](api.md).

## Generator default

`BrawoCms::Engine` configures `g.test_framework :rspec` for new engine artifacts.
