# BrawoCMS Docs

Rails engine for code-first content management: define content types, taxonomies, and blocks in Ruby; get an admin UI and JSON API automatically.

## What you can do

| Capability | Guide |
|------------|-------|
| Define structured content (posts, pages, products, …) | [Content types](content-types.md) |
| Classify content (categories, tags, …) | [Taxonomies](taxonomies.md) |
| Build pages from reusable blocks | [Blocks](blocks.md) |
| Manage content in the browser | [Admin](admin.md) |
| Understand how it all fits together | [Architecture](architecture.md) |

## Quick setup

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

## How it works

```
Your models (Post, Page, Category, …)
  → content_type / taxonomy_type DSL
  → BrawoCms registry (in-memory)
  → Admin UI + API auto-generated from field defs
```

**Storage:** one `brawo_cms_contents` table (STI), one `brawo_cms_taxonomies` table. Custom fields in JSONB `fields` column — no migration per field.

## API

API documentation is maintained in OpenAPI (Swagger):

- **Interactive docs:** `/admin/api/docs` (Swagger UI)
- **Raw spec:** `openapi/v1/swagger.yaml` in the gem

No separate markdown API reference — Swagger is the source of truth for endpoints, request/response shapes, and auth.

## Contributors

Engine development docs: [development/index.md](development/index.md)
