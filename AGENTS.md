# Brawo CMS — agent guide

Rails **engine** mounted at `/admin`. Host app defines STI models (`Article`, `Category`, …) with `content_type` / `taxonomy_type` DSL; types register in memory on boot (`BrawoCms.content_types`, `BrawoCms.taxonomy_types`). Storage: `brawo_cms_contents` and `brawo_cms_taxonomies` with JSONB `fields`.

## Where to edit

| Area | Paths |
|------|--------|
| Admin UI | `app/views/brawo_cms/admin/`, `app/helpers/brawo_cms/admin/`, `app/assets/stylesheets/brawo_cms/` |
| Admin controllers | `app/controllers/brawo_cms/admin/` |
| API | `app/controllers/brawo_cms/api/v1/`, `app/serializers/brawo_cms/` |
| Writes / validation | `app/services/brawo_cms/` (`ContentService`, `TaxonomyService`, `ParamsBuilder`) |
| Field widgets | `app/models/brawo_cms/fields/`, `FieldFactory` |
| Frontend blocks | `app/helpers/brawo_cms/blocks_helper.rb`, `app/blocks/`, host `app/blocks/` |
| Routes | `config/routes.rb` (engine) |
| Demo / integration tests | `test/dummy/app/models/` |
| User docs | `docs/` — start at [docs/index.md](docs/index.md) |
| Contributor internals | [docs/development/admin-internals.md](docs/development/admin-internals.md), [docs/development/testing.md](docs/development/testing.md) |

## Running the app (Docker)

No Ruby on the host — everything runs in the compose stack (`docker-compose.yml`): `brawo-web-1` (repo mounted at `/app`) and `brawo-db-1` (Postgres 16, host port 5433). Dev server: `http://localhost:3000` (admin at `/admin`).

```bash
./setup.sh                            # build, up, migrate, seed dummy app
docker compose up -d                  # start stack
docker compose down                   # stop stack
docker compose logs -f web            # server logs
```

## Commands

Run inside the `web` container:

```bash
# full suite (boots test/dummy)
docker exec brawo-web-1 bash -lc 'cd /app && bundle exec rspec'

# regen openapi/v1/swagger.yaml from request specs
docker exec brawo-web-1 bash -lc 'cd /app && bundle exec rake openapi:generate'

# one-off script against the dummy app (console equivalent)
docker exec brawo-web-1 bash -lc 'cd /app/test/dummy && bin/rails runner "puts Article.published.to_sql"'

# re-seed sample data
docker exec brawo-web-1 bash -lc 'cd /app/test/dummy && bin/rails db:seed'
```

Request logs land in `test/dummy/log/development.log` (host path) — check there first when debugging a 404/500; SQL bind values in the log show exactly which scope filtered a record out. Quick smoke test: `curl -s -o /dev/null -w "%{http_code}\n" http://localhost:3000/articles/<slug>`.

If the suite fails with `ActiveRecord::EnvironmentMismatchError` on `db:test:load_schema`, the test DB was last marked `development`: run `docker exec brawo-web-1 bash -lc 'cd /app/test/dummy && bin/rails db:environment:set RAILS_ENV=test'`.

After new engine migrations, sync to dummy (see [docs/development/testing.md](docs/development/testing.md) or `./setup.sh`).

## Principles

- **Thin controllers**, **services for create/update/destroy**, serializers for API JSON.
- **Helpers + partials** for admin HTML; field classes implement `render_input` / `display_value`.
- **No** `BrawoCms::ContentType` ActiveRecord model — registry only.
- **No** per-field host migrations — custom data lives in JSONB `fields`.
- **Minimize diff**; match existing names (`brawo_*` helpers, `BrawoCms::Admin::*`, i18n `brawo.*`).
- **Avoid new abstractions** until the same pattern appears at least twice; prefer shared partials over meta-controllers.
- **Run `bundle exec rspec`** before finishing engine changes.

## Cursor rules & skills

- Rules: [.cursor/rules/](.cursor/rules/) (auto-loaded by Cursor).
- Skills: [.cursor/skills/](.cursor/skills/) for field types, admin features, API changes.
