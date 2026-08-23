# BrawoCMS

Rails mountable engine: content types + taxonomies, JSONB custom fields, auto-generated admin (Bootstrap). One shared table for all content (STI), one for taxonomies. **PostgreSQL required** (JSONB). Targets **Rails ≥ 7.1**, **Ruby 3.3** in Docker image.

## What you get

- DSL on your models: `content_type` / `taxonomy_type` with `fields: [...]`
- Admin at mount path (`/admin` in docs below): CRUD for contents + taxonomies, drafts / published / archived, slug from title
- JSON API at `/admin/api/v1` (relative to mount path): CRUD + type metadata; optional bearer token via `BrawoCms.api_token`
- OpenAPI docs at `/admin/api/docs` (Swagger UI); spec in `openapi/v1/swagger.yaml`
- Generators: `brawo_cms:content_type`, `brawo_cms:taxonomy_type` (with `--routes`, `--root-path`, `--public-archive` flags — see [docs/content-types.md](docs/content-types.md))
- Demo app: `test/dummy` (Articles, Products, Categories, references + repeaters on Article)



## Field types (engine)


| Type                     | Notes                                     |
| ------------------------ | ----------------------------------------- |
| `:string` / `:text`      | Single line                               |
| `:textarea`              | Multiline                                 |
| `:number` / `:integer`   | Numeric                                   |
| `:date`, `:datetime`     | Date / time                               |
| `:boolean` / `:checkbox` | Toggle                                    |
| `:select`                | `choices: [[label, value], ...]`          |
| `:taxonomy`              | `taxonomy_type: :your_type` — stores id   |
| `:reference`             | `model_class: 'ModelName'` — array of ids |
| `:repeater`              | Nested `sub_fields:` (can nest repeaters) |




## Try the demo (Docker)

Fast path:

```bash
chmod +x setup.sh && ./setup.sh
```

Or: `docker-compose build && docker-compose up -d`, then copy engine migrations into the dummy app and migrate (see `setup.sh` for the exact pattern).

- Site: [http://localhost:3000](http://localhost:3000)  
- Admin: [http://localhost:3000/admin](http://localhost:3000/admin)  
- Postgres published on host **5433** → container 5432 (avoids clashing with local Postgres)

Details: [docs/development/docker.md](docs/development/docker.md) (Docker Compose or **Dev Container**)

## Use in your own Rails app

1. Gemfile: `gem "brawo_cms"` (or `path:` / `git:` while developing).
2. `bundle install`
3. Copy engine migrations, then migrate:
  ```bash
   bin/rails railties:install:migrations
   bin/rails db:migrate
  ```
4. Mount engine in `config/routes.rb`:
  ```ruby
   mount BrawoCms::Engine => "/admin"
  ```
5. **Eager-load content/taxonomy models** so they register (example from dummy):
  ```ruby
   # config/initializers/brawo_cms.rb
   Rails.application.config.to_prepare do
     Dir[Rails.root.join("app/models/**/*.rb")].each { |f| require_dependency f }
   end
  ```
6. Define models inheriting `BrawoCms::Content` / `BrawoCms::Taxonomy` with `include BrawoCms::ContentTypeable` / `TaxonomyTypeable`. See [docs/index.md](docs/index.md) and generator READMEs under `lib/generators/brawo_cms/`.



## Repo layout

- `app/` — engine admin UI, models, fields, assets (`brawo_cms/admin.css`, Stimulus via importmap)
- `config/routes.rb` — engine routes (`admin/contents`, `admin/taxonomies`)
- `db/migrate/` — engine migrations (contents + taxonomies tables)
- `lib/brawo_cms/` — engine + version **0.1.0**
- `test/dummy/` — runnable demo Rails app
- `spec/` — RSpec (boots `test/dummy` via `spec/rails_helper.rb`)
- `openapi/` — generated OpenAPI spec (`v1/swagger.yaml`)



## API docs (OpenAPI / rswag)

- **Swagger UI:** `http://localhost:3000/admin/api/docs` (dummy app / Docker demo)
- **Raw spec:** `openapi/v1/swagger.yaml` in the gem

API endpoint documentation lives in Swagger — not in markdown. To regenerate the spec after changing API request specs, see [docs/development/testing.md](docs/development/testing.md).

Host apps need `rswag-api` and `rswag-ui` in the bundle for the interactive UI (included in this repo’s Gemfile). Mount paths assume default engine mount `/admin`.

## More docs

- [docs/index.md](docs/index.md) — **content types, taxonomies, blocks, admin, architecture**
- [docs/development/index.md](docs/development/index.md) — contributing, testing, Docker demo



## License

MIT — see [MIT-LICENSE](MIT-LICENSE).