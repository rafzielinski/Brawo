# BrawoCMS Docs

Rails engine: code-first content types, taxonomies, blocks, admin UI, JSON API.

## Pages

| Topic | What it covers |
|-------|----------------|
| [Content Types](content-types.md) | Define models, fields, generators, querying |
| [Taxonomies](taxonomies.md) | Categories/tags, linking to content |
| [Blocks](blocks.md) | Page builder, block DSL, frontend rendering |
| [Admin](admin.md) | Dashboard, CRUD, routes, status workflow |
| [API](api.md) | REST endpoints, auth, OpenAPI |

## Setup (30 seconds)

```ruby
# Gemfile
gem "brawo_cms"

# config/routes.rb
mount BrawoCms::Engine => "/admin"

# config/initializers/brawo_cms.rb
Rails.application.config.to_prepare do
  Dir[Rails.root.join("app/models/**/*.rb")].each { |f| require_dependency f }
end
```

```bash
bin/rails railties:install:migrations && bin/rails db:migrate
```

- Admin: `/admin`
- API: `/admin/api/v1`
- Swagger: `/admin/api/docs`

## How it works

```
Your models (Article, Category, Page)
  → content_type / taxonomy_type DSL
  → BrawoCms registry (in-memory)
  → Admin UI + API auto-generated from field defs
```

**Storage:** one `brawo_cms_contents` table (STI), one `brawo_cms_taxonomies` table. Custom fields in JSONB `fields` column — no migration per field.

**Demo app:** `test/dummy` — Article, Product, Page, Category.

## Also see

- [QUICKSTART.md](QUICKSTART.md) — Docker demo
- [architecture.md](architecture.md) — layer diagrams
- [DEVELOPMENT.md](DEVELOPMENT.md) — contributing
