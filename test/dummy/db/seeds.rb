# frozen_string_literal: true

puts "Seeding BrawoCMS demo data..."

# ---------------------------------------------------------------------------
# Taxonomies: Category
# ---------------------------------------------------------------------------

categories = [
  {
    name: "Technology",
    slug: "technology",
    description: "Articles and news about software, hardware, and digital trends.",
    color: "#3B82F6",
    icon: "fa-microchip",
    order: 1
  },
  {
    name: "Business",
    slug: "business",
    description: "Strategy, leadership, and industry insights.",
    color: "#10B981",
    icon: "fa-briefcase",
    order: 2
  },
  {
    name: "Guides",
    slug: "guides",
    description: "Step-by-step tutorials and how-to content.",
    color: "#F59E0B",
    icon: "fa-book-open",
    order: 3
  }
].map do |attrs|
  Category.find_or_initialize_by(slug: attrs[:slug]).tap do |category|
    category.name = attrs[:name]
    category.description = attrs[:description]
    category.color = attrs[:color]
    category.icon = attrs[:icon]
    category.order = attrs[:order]
    category.save!
  end
end

tech, business, guides = categories

# ---------------------------------------------------------------------------
# Content types: Product
# ---------------------------------------------------------------------------

products = [
  {
    title: "Premium Subscription",
    slug: "premium-subscription",
    description: "Full access to all features and priority support.",
    status: "published",
    published_at: 2.weeks.ago,
    price: 29.99,
    sku: "PREM-001",
    stock_quantity: 100,
    product_description: "Unlock the complete BrawoCMS experience with unlimited content types, advanced taxonomies, and priority email support.",
    featured_product: true,
    availability: "in_stock"
  },
  {
    title: "Starter Kit",
    slug: "starter-kit",
    description: "Everything you need to launch your first CMS-powered site.",
    status: "published",
    published_at: 1.month.ago,
    price: 9.99,
    sku: "START-001",
    stock_quantity: 250,
    product_description: "A lightweight package with core content management features, perfect for small projects and prototypes.",
    featured_product: false,
    availability: "in_stock"
  },
  {
    title: "Enterprise License",
    slug: "enterprise-license",
    description: "Custom deployment with dedicated support and SLA.",
    status: "published",
    published_at: 3.days.ago,
    price: 499.00,
    sku: "ENT-001",
    stock_quantity: 0,
    product_description: "Tailored for large teams. Includes SSO, audit logs, custom integrations, and a dedicated account manager.",
    featured_product: true,
    availability: "preorder"
  },
  {
    title: "Legacy Theme Pack",
    slug: "legacy-theme-pack",
    description: "Discontinued theme collection — no longer available for purchase.",
    status: "archived",
    published_at: 1.year.ago,
    price: 14.99,
    sku: "THEME-OLD",
    stock_quantity: 0,
    product_description: "This theme pack has been retired. Existing customers retain access to downloaded assets.",
    featured_product: false,
    availability: "out_of_stock"
  },
  {
    title: "API Add-on",
    slug: "api-addon",
    description: "REST API access for headless content delivery.",
    status: "draft",
    price: 19.99,
    sku: "API-001",
    stock_quantity: 50,
    product_description: "Expose your content via a JSON API. Draft — not yet available for purchase.",
    featured_product: false,
    availability: "in_stock"
  }
].map do |attrs|
  Product.find_or_initialize_by(slug: attrs[:slug]).tap do |product|
    product.assign_attributes(attrs.except(:slug))
    product.save!
  end
end

premium, starter, enterprise, _legacy, _api_addon = products

# ---------------------------------------------------------------------------
# Content types: Article
# ---------------------------------------------------------------------------

articles = [
  {
    title: "Getting Started with BrawoCMS",
    slug: "getting-started-with-brawocms",
    description: "Learn how to set up and configure BrawoCMS in your Rails application.",
    status: "published",
    published_at: 1.week.ago,
    author: "John Doe",
    body: "BrawoCMS is a flexible content management engine for Rails. This guide walks you through installation, defining content types, and seeding your first records.\n\nAfter mounting the engine and running migrations, register your models with the content_type DSL and start creating content from the admin panel or via the API.",
    published_date: 1.week.ago.to_date.to_s,
    featured: true,
    category_id: tech.id,
    related_products: [premium.id, starter.id],
    faq_items: [
      {
        question: "Do I need Docker?",
        answer: "No — Docker is optional. You can run the demo app with a local Postgres instance instead.",
        published: true,
        sub_items: [
          {
            sub_item_question: "What Postgres version is supported?",
            sub_item_answer: "PostgreSQL 14 or later is recommended."
          }
        ]
      },
      {
        question: "Can I add custom fields?",
        answer: "Yes. Define fields in your content_type block and they are stored in the JSONB fields column.",
        published: true,
        sub_items: []
      }
    ]
  },
  {
    title: "Tips for Content Structure",
    slug: "tips-for-content-structure",
    description: "Best practices for organizing articles, products, and taxonomies.",
    status: "published",
    published_at: 2.weeks.ago,
    author: "Jane Smith",
    body: "Start with taxonomies before content that references them. Use slugs consistently and keep draft content out of public scopes until you are ready to publish.\n\nRepeater fields are great for FAQs, feature lists, and nested blocks without extra tables.",
    published_date: 2.weeks.ago.to_date.to_s,
    featured: false,
    category_id: business.id,
    related_products: [enterprise.id],
    faq_items: [
      {
        question: "How do I link articles to products?",
        answer: "Use a reference field with model_class set to your product model.",
        published: true,
        sub_items: [
          {
            sub_item_question: "Can I reference multiple products?",
            sub_item_answer: "Yes — reference fields store an array of IDs."
          },
          {
            sub_item_question: "What about the reverse link?",
            sub_item_answer: "Query products by ID from the article's related_products field in your views or API."
          }
        ]
      }
    ]
  },
  {
    title: "Building a Headless CMS Workflow",
    slug: "building-a-headless-cms-workflow",
    description: "Use the JSON API to deliver content to a separate frontend.",
    status: "published",
    published_at: 3.days.ago,
    author: "Alex Rivera",
    body: "BrawoCMS exposes REST endpoints under /admin/api/v1. Fetch published articles and products from your React, Vue, or mobile app without rendering Rails views.\n\nFilter by status server-side and cache responses at the edge for best performance.",
    published_date: 3.days.ago.to_date.to_s,
    featured: true,
    category_id: guides.id,
    related_products: [premium.id, enterprise.id],
    faq_items: [
      {
        question: "Is authentication required for the API?",
        answer: "Admin API routes require an authenticated session. Public read endpoints depend on your host app configuration.",
        published: true,
        sub_items: []
      }
    ]
  },
  {
    title: "Draft: Upcoming Features",
    slug: "draft-upcoming-features",
    description: "A preview of features still in development.",
    status: "draft",
    author: "Editorial Team",
    body: "This article is not published yet. It will cover media library improvements and workflow approvals.",
    published_date: Date.today.to_s,
    featured: false,
    category_id: tech.id,
    related_products: [],
    faq_items: []
  },
  {
    title: "Archived: 2024 Release Notes",
    slug: "archived-2024-release-notes",
    description: "Historical release notes from the 2024 launch.",
    status: "archived",
    published_at: 6.months.ago,
    author: "BrawoCMS Team",
    body: "Version 1.0 shipped in 2024 with content types, taxonomies, and admin UI. This post is kept for reference only.",
    published_date: 6.months.ago.to_date.to_s,
    featured: false,
    category_id: guides.id,
    related_products: [starter.id],
    faq_items: [
      {
        question: "Where are current release notes?",
        answer: "See the project README and CHANGELOG on GitHub.",
        published: false,
        sub_items: []
      }
    ]
  }
].map do |attrs|
  Article.find_or_initialize_by(slug: attrs[:slug]).tap do |article|
    article.assign_attributes(attrs.except(:slug))
    article.save!
  end
end

puts "Seeded #{Category.count} categories, #{Product.count} products, #{Article.count} articles."
