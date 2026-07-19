# Content Types

Content types are host-app models that inherit `BrawoCms::Content` and declare fields via DSL. Registered at boot into `BrawoCms.content_types`.

## Define a content type

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: "Article",
    fields: [
      { name: :author, type: :string, label: "Author" },
      { name: :body, type: :textarea, label: "Body" },
      { name: :featured, type: :boolean, label: "Featured" },
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: "Category" },
      { name: :related_products, type: :reference, model_class: "Product", label: "Related" },
      { name: :faq_items, type: :repeater, label: "FAQ", sub_fields: [
        { name: :question, type: :string },
        { name: :answer, type: :textarea }
      ]}
    ]
end
```

Or generate:

```bash
rails g brawo_cms:content_type Post author:string body:textarea
```

## Base attributes (table columns)

| Column | Purpose |
|--------|---------|
| `title` | Required display title |
| `slug` | URL slug, auto-generated from title |
| `description` | Short summary |
| `status` | `draft` / `published` / `archived` |
| `published_at` | Publish timestamp |
| `fields` | JSONB — all custom fields |

Custom fields never get their own DB columns.

## Field types

| Type | Options | Stores |
|------|---------|--------|
| `:string` / `:text` | `label`, `help_text`, `required` | string |
| `:textarea` | same | string |
| `:number` / `:integer` | same | number |
| `:date` / `:datetime` | same | ISO date/time |
| `:boolean` / `:checkbox` | same | boolean |
| `:select` | `choices: [["Label", "value"], ...]` | string |
| `:taxonomy` | `taxonomy_type: :category` | taxonomy term id |
| `:reference` | `model_class: "Product"` | array of ids |
| `:repeater` | `sub_fields: [...]` | array of hashes (nestable) |
| `:blocks` | — | block array (see [Blocks](blocks.md)) |

Common keys: `name`, `type`, `label`, `help_text`, `required`.

### Field wrapper (admin layout)

Control how a field renders in admin forms. Width maps to Bootstrap columns (`col-12` on mobile, `col-md-*` on tablet+). Default is full width (`100` → `col-12`).

```ruby
{
  name: :author,
  type: :string,
  label: "Author",
  wrapper: {
    width: "50",                              # → col-md-6 (12-col grid)
    class: "custom-class",                    # extra CSS class on wrapper
    attr: { "data-custom-attr" => "value" } # or string: 'data-custom-attr="value"'
  }
}
```

Common widths: `50` → half, `33` → third, `25` → quarter, `100` → full. Other values round to the nearest column.

Works on top-level fields, repeater `sub_fields`, block `field()` definitions, and nested repeaters.

## Content type options

```ruby
content_type :page,
  label: "Page",
  page_builder: true,           # visual block editor
  allowed_blocks: [:heading, :text],  # optional filter
  excluded_blocks: [:faq],      # optional filter
  fields: [...]
```

## Query & use

```ruby
# Scopes
Article.published
Article.drafts

# Field accessors (auto-generated)
article.author
article.body = "Hello"
article.faq_items  # => [{ "question" => "...", "answer" => "..." }]

# Resolve references
article.related_products_list  # custom helper in demo
Category.find_by(id: article.category_id)
```

Public site queries models directly — no engine service layer needed.

## Demo types

| Type | Model | Notable fields |
|------|-------|----------------|
| `article` | `Article` | taxonomy, reference, nested repeater |
| `product` | `Product` | price, SKU, select (availability) |
| `page` | `Page` | `:blocks` field, `page_builder: true` |

See `test/dummy/app/models/`.

## Admin & API

- Admin: `/admin/contents?content_type=article`
- API: `GET/POST/PATCH/DELETE /admin/api/v1/contents?content_type=article`
- Schema: `GET /admin/api/v1/content_types` or `/content_types/article`
