# Taxonomies

## What is a taxonomy?

A taxonomy is a classification vocabulary — categories, tags, regions, or any grouping scheme. Taxonomy types follow the same DSL pattern as content types but are simpler: no status or publishing workflow. Terms share one `brawo_cms_taxonomies` table (STI).

Link taxonomies to content via a `:taxonomy` field on your content type (see [Content types](content-types.md)).

## Create your first taxonomy type

### 1. Define the model

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: "Category",
    fields: [
      { name: :color, type: :string, label: "Color" },
      { name: :icon, type: :string, label: "Icon Class" },
      { name: :order, type: :number, label: "Sort Order" }
    ]
end
```

### 2. Restart the server

Taxonomy types register on boot. Restart after adding or changing a type.

### 3. Manage terms

- **Admin:** `/admin/taxonomies?taxonomy_type=category`
- **API:** `/admin/api/v1/taxonomies?taxonomy_type=category` — see [Swagger UI](/admin/api/docs) for payloads

Or generate a scaffold:

```bash
rails g brawo_cms:taxonomy_type Category color:string order:integer
```

## Base attributes

| Column | Purpose |
|--------|---------|
| `name` | Display name |
| `slug` | URL slug, auto-generated |
| `description` | Optional text |
| `fields` | JSONB custom fields |

Table: `brawo_cms_taxonomies` (STI via `type` column).

## Link to content

Add a `:taxonomy` field on your content type:

```ruby
{ name: :category_id, type: :taxonomy, taxonomy_type: :category, label: "Category" }
```

Stores the term's id in `fields` JSONB. Resolve in your model:

```ruby
def category
  Category.find_by(id: category_id) if category_id.present?
end
```

Taxonomies can also reference themselves (e.g. `parent_id` with `taxonomy_type: :category`).

## Query

```ruby
Category.all
category.color       # custom field accessor
category.name
```

## Admin & API

- **Admin:** `/admin/taxonomies?taxonomy_type=<type>`
- **API:** `/admin/api/v1/taxonomies?taxonomy_type=<type>` — full details in [Swagger UI](/admin/api/docs)
- **Schema introspection:** `/admin/api/v1/taxonomy_types` or `/taxonomy_types/<type>`

Sidebar auto-lists all registered taxonomy types alongside content types.

## Terminology

| Term | Meaning |
|------|---------|
| Taxonomy type | Schema class (`Category`) — registered in `BrawoCms.taxonomy_types` |
| Taxonomy term | One row in `brawo_cms_taxonomies` (a single category) |

No separate `Term` model.

## Generators

```bash
# Model only
rails g brawo_cms:taxonomy_type Category color:string

# Public archive at configurable prefix (default: /categories/:slug)
rails g brawo_cms:taxonomy_type Category color:string --public-archive --routes

# Custom route prefix
rails g brawo_cms:taxonomy_type Category --routes --route-prefix=topics
```

## Route prefix config

```ruby
# config/initializers/brawo_cms.rb
BrawoCms.configure do |config|
  config.taxonomy_route_prefixes = {
    category: "categories",
    tag: "tags"
  }
end
```

Unset types default to the pluralized taxonomy name (`tag` → `/tags/:slug`).

