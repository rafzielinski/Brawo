# Taxonomies

Taxonomies are classification vocabularies (categories, tags, etc.). Same pattern as content types but simpler — no status/publishing.

## Define a taxonomy type

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

Or generate:

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

- Admin: `/admin/taxonomies?taxonomy_type=category`
- API: `GET/POST/PATCH/DELETE /admin/api/v1/taxonomies?taxonomy_type=category`
- Schema: `GET /admin/api/v1/taxonomy_types` or `/taxonomy_types/category`

Sidebar auto-lists all registered taxonomy types alongside content types.

## Terminology

| Term | Meaning |
|------|---------|
| Taxonomy type | Schema class (`Category`) — registered in `BrawoCms.taxonomy_types` |
| Taxonomy term | One row in `brawo_cms_taxonomies` (a single category) |

No separate `Term` model.
