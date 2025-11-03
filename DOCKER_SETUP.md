# BrawoCMS Docker Setup

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Build and start the containers:

```bash
docker-compose build
docker-compose up
```

2. In a new terminal, set up the database:

```bash
docker-compose exec web bash
cd test/dummy
rails db:create
rails db:migrate
```

3. (Optional) Seed some sample data:

```bash
rails console
```

```ruby
# Create sample articles
Article.create!(
  title: "Getting Started with BrawoCMS",
  description: "Learn how to build powerful content management systems with Rails",
  status: "published",
  author: "John Doe",
  body: "This is a comprehensive guide to getting started with BrawoCMS...",
  published_date: Date.today.to_s,
  category: "tech",
  featured: true
)

Article.create!(
  title: "Advanced CMS Patterns",
  description: "Deep dive into content type architecture",
  status: "published",
  author: "Jane Smith",
  body: "In this article, we explore advanced patterns for building flexible CMS...",
  published_date: (Date.today - 7).to_s,
  category: "tech",
  featured: false
)

# Create sample products
Product.create!(
  title: "Premium Subscription",
  description: "Access all premium features",
  status: "published",
  price: 29.99,
  sku: "PREM-001",
  stock_quantity: 100,
  product_description: "Get unlimited access to all premium features including...",
  availability: "in_stock",
  featured_product: true
)

Product.create!(
  title: "Starter Package",
  description: "Perfect for beginners",
  status: "published",
  price: 9.99,
  sku: "START-001",
  stock_quantity: 50,
  product_description: "Start your journey with our basic package...",
  availability: "in_stock",
  featured_product: false
)
```

4. Access the application:

- Main site: http://localhost:3000
- Admin panel: http://localhost:3000/admin
- Articles: http://localhost:3000/articles
- Products: http://localhost:3000/products

## Useful Commands

### Start services in background:
```bash
docker-compose up -d
```

### View logs:
```bash
docker-compose logs -f web
```

### Stop services:
```bash
docker-compose down
```

### Access Rails console:
```bash
docker-compose exec web bash
cd test/dummy
rails console
```

### Run migrations:
```bash
docker-compose exec web bash
cd test/dummy
rails db:migrate
```

### Reset database:
```bash
docker-compose exec web bash
cd test/dummy
rails db:drop db:create db:migrate
```

## Troubleshooting

### Database connection issues
If you see database connection errors, make sure the PostgreSQL container is running:
```bash
docker-compose ps
```

### Port conflicts
The project is configured to use:
- **Port 3000** for the Rails application
- **Port 5433** for PostgreSQL (to avoid conflicts with local PostgreSQL on 5432)

If you still encounter port conflicts, modify the ports in `docker-compose.yml`

### Permission issues
If you encounter permission issues with files:
```bash
docker-compose exec web bash
chmod +x test/dummy/bin/rails test/dummy/bin/rake
```

