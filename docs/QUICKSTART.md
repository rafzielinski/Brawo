# Quick start

Get the **demo app** running, click around admin, optional sample records.

## Prerequisites

- Docker + Docker Compose

## One-shot setup (recommended)

From repo root:

```bash
chmod +x setup.sh
./setup.sh
```

This builds images, starts `web` + `db`, waits for Postgres, copies `db/migrate/*.rb` into `test/dummy/db/migrate/`, runs `rails db:create db:migrate` inside `test/dummy`.

**Port note:** `docker-compose.yml` maps Postgres to **5433** on your machine so it does not fight a local Postgres on 5432.

## Open the app

| URL | What |
|-----|------|
| http://localhost:3000 | Demo site (home, articles, products) |
| http://localhost:3000/admin | CMS admin (dashboard, contents, taxonomies) |

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

Manual DB (only if you did not use `setup.sh`):

```bash
docker-compose exec web bash -c 'mkdir -p test/dummy/db/migrate && cp db/migrate/*.rb test/dummy/db/migrate/ 2>/dev/null; cd test/dummy && rails db:create db:migrate'
```

## Next steps

- Use **BrawoCMS in your app**: follow [README.md](README.md) (gem, migrations, mount, initializer).  
- Deeper structure / overrides: [DEVELOPMENT.md](DEVELOPMENT.md).  
- Docker-only reference: [DOCKER_SETUP.md](DOCKER_SETUP.md).

## Note on `dev.sh`

`dev.sh` targets extra Compose services (`brawo_cms`, `test`) that are **not** in the current `docker-compose.yml`. Prefer `setup.sh` + `docker-compose` for this repo’s demo workflow.
