# Docker demo

Run the bundled demo app (`test/dummy`) via Docker Compose or Dev Container.

## Prerequisites

- Docker + Docker Compose
- Image thumbnails need **libvips** in the `web` / devcontainer image (included in the project Dockerfiles). Rebuild after pulling Dockerfile changes: `docker-compose build` or Dev Container **Rebuild Container**.

## One-shot setup (recommended)

From repo root:

```bash
chmod +x setup.sh
./setup.sh
```

This builds images, starts `web` + `db`, waits for Postgres, copies `db/migrate/*.rb` into `test/dummy/db/migrate/`, runs `rails db:create db:migrate` inside `test/dummy`.

**Port note:** `docker-compose.yml` maps Postgres to **5433** on your machine so it does not fight a local Postgres on 5432.

## Manual setup

```bash
docker-compose build
docker-compose up -d
```

Then set up the database:

```bash
docker-compose exec web bash
cd test/dummy
rails db:create
rails db:migrate
```

Or sync migrations from the engine:

```bash
docker-compose exec web bash -c 'mkdir -p test/dummy/db/migrate && cp db/migrate/*.rb test/dummy/db/migrate/ 2>/dev/null; cd test/dummy && rails db:create db:migrate'
```

## Open the app

| URL | What |
|-----|------|
| http://localhost:3000 | Demo site (home, articles, products) |
| http://localhost:3000/admin | CMS admin (dashboard, contents, taxonomies) |
| http://localhost:3000/admin/api/docs | Swagger UI |

Dummy app mounts engine at `/admin` (`test/dummy/config/routes.rb`).

## First clicks in admin

1. Open http://localhost:3000/admin
2. Sidebar: **Taxonomies → Categories** — create a category (name + slug). Articles link here via `category_id`.
3. **Articles** or **Products** — New → fill fields → save.
4. Open http://localhost:3000/articles or `/products` to see public views.

Demo models live in `test/dummy/app/models/` (`article.rb`, `product.rb`, `category.rb`).

## Optional: sample data in console

```bash
docker-compose exec web bash
cd test/dummy
rails console
```

Articles use **taxonomy** `category_id`, not a string `category`. Seed categories first, then articles:

```ruby
tech = Category.create!(name: "Technology", slug: "tech", description: "Tech")
biz  = Category.create!(name: "Business", slug: "business", description: "Business")

Article.create!(
  title: "Getting Started with BrawoCMS",
  description: "Learn how to use the engine",
  status: "published",
  author: "John Doe",
  body: "Short intro body.",
  published_date: Date.today.to_s,
  category_id: tech.id,
  featured: true
)

Article.create!(
  title: "Tips for content structure",
  description: "Organize content effectively",
  status: "published",
  author: "Jane Smith",
  body: "More body text here.",
  published_date: (Date.today - 7).to_s,
  category_id: biz.id,
  featured: false
)

Product.create!(
  title: "Premium Subscription",
  description: "Premium tier",
  status: "published",
  price: 29.99,
  sku: "PREM-001",
  stock_quantity: 100,
  product_description: "Full feature set.",
  availability: "in_stock",
  featured_product: true
)

puts "Articles: #{Article.count}, Products: #{Product.count}, Categories: #{Category.count}"
```

## Add a content type in the demo

Inside container, `cd test/dummy`, then:

```bash
rails generate brawo_cms:content_type Event name:string location:string event_date:date
```

Restart server if needed so the new model registers.

## Everyday commands

```bash
docker-compose logs -f web    # logs
docker-compose down           # stop
docker-compose up -d          # start again
```

### Access Rails console

```bash
docker-compose exec web bash
cd test/dummy
rails console
```

### Reset database

```bash
docker-compose exec web bash
cd test/dummy
rails db:drop db:create db:migrate
```

## Dev Container (Cursor / VS Code)

Open the repo in a **Dev Container**. `postCreateCommand` runs [`.devcontainer/post-create.sh`](../../.devcontainer/post-create.sh) (`bundle install`, sync migrations, `db:prepare`).

```bash
cd test/dummy && bundle exec rails server -b 0.0.0.0   # from /workspace
bundle exec rspec                                      # tests from gem root
```

Admin UI: http://localhost:3000/admin/admin (engine mount + admin namespace).

## Troubleshooting

### Database connection issues

If you see database connection errors, make sure the PostgreSQL container is running:

```bash
docker-compose ps
```

### Port conflicts

The project uses:

- **Port 3000** for the Rails application
- **Port 5433** for PostgreSQL (to avoid conflicts with local PostgreSQL on 5432)

If you still encounter port conflicts, modify the ports in `docker-compose.yml`.

### Thumbnail / libvips errors

If admin media thumbnails 500 with `Could not open library 'vips.so.42'`, install libvips in the image and rebuild:

```bash
docker-compose build --no-cache web
docker-compose up -d
```

Dev Container: **Rebuild Container** from the command palette. Then restart Rails.

Existing uploads work after rebuild — first thumb request generates the variant (no re-upload needed).

## Next steps

- Use Brawo CMS in your app: [../index.md](../index.md) and [../../README.md](../../README.md)
- Engine development: [contributing.md](contributing.md), [testing.md](testing.md)
