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
| Contributor internals | [docs/admin-internals.md](docs/admin-internals.md), [docs/testing.md](docs/testing.md) |

## Commands

```bash
bundle exec rspec                    # full suite (boots test/dummy)
bundle exec rake openapi:generate    # regen openapi/v1/swagger.yaml from request specs
```

After new engine migrations, sync to dummy (see [docs/testing.md](docs/testing.md) or `./setup.sh`).

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
