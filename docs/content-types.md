# Content Types

## What is a content type?

A content type is a schema for structured content in your app — blog posts, landing pages, products, events, or anything else you model. You define it as a Ruby class inheriting `BrawoCms::Content`, declare fields via DSL, and Brawo CMS registers it at boot. The admin UI and API are generated from your field definitions.

Custom field data lives in a JSONB `fields` column — no migration per field.

## Create your first content type

### 1. Define the model

```ruby
class Post < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :post,
    label: "Post",
    fields: [
      { name: :author, type: :string, label: "Author" },
      { name: :body, type: :textarea, label: "Body" },
      { name: :featured, type: :boolean, label: "Featured" }
    ]
end
```

### 2. Restart the server

Models register on boot. After adding or changing a content type, restart so it appears in the admin sidebar.

### 3. Manage content

- **Admin:** `/admin/contents?content_type=post`
- **API:** `/admin/api/v1/contents?content_type=post` — see [Swagger UI](/admin/api/docs) for payloads

Or generate a scaffold:

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

## Field types

| Type | Options | Stores |
|------|---------|--------|
| `:string` / `:text` | `label`, `help_text`, `required` | string |
| `:textarea` | same | string |
| `:number` / `:integer` | same | number |
| `:date` / `:datetime` | same | ISO date/time |
| `:boolean` / `:checkbox` | same | boolean |
| `:select` | `choices: [["Label", "value"], ...]` | string |
| `:color` | `swatches: ["#hex", ...]`, `alpha: false` to disable transparency | hex string (`#rrggbb` or `#rrggbbaa`) |
| `:icon` | `choices:` optional subset, `variant: :outline` / `:fill` | Bootstrap Icons name (e.g. `pencil`) |
| `:url` | `default_scheme: "https"`, `allowed_schemes: ["https", "http", "ftp"]` | full URL string |
| `:email` | same as string | string |
| `:taxonomy` | `taxonomy_type: :category` | taxonomy term id — see [Taxonomies](taxonomies.md) |
| `:reference` | `model_class: "Product"` | array of ids |
| `:repeater` | `sub_fields: [...]` | array of hashes (nestable) |
| `:blocks` | — | block array — see [Blocks](blocks.md) |

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

## Full example

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

## Query & use

```ruby
# Scopes
Article.published
Article.drafts

# Field accessors (auto-generated)
article.author
article.body = "Hello"
article.faq_items  # => [{ "question" => "...", "answer" => "..." }]

# Resolve references and taxonomies
article.related_products_list  # custom helper
Category.find_by(id: article.category_id)
```

Public site queries models directly — no engine service layer needed.

## Admin & API

- **Admin:** `/admin/contents?content_type=<type>`
- **API:** `/admin/api/v1/contents?content_type=<type>` — full details in [Swagger UI](/admin/api/docs)
- **Schema introspection:** `/admin/api/v1/content_types` or `/content_types/<type>`

## Generators

```bash
# Model only
rails g brawo_cms:content_type Post author:string body:textarea

# Public site at /posts/:slug
rails g brawo_cms:content_type Post author:string body:textarea --public-controller --public-views --routes

# Page at /:slug with page builder (defaults for Page)
rails g brawo_cms:content_type Page --page-builder --root-path
```

| Flag | Effect |
|------|--------|
| `--public-controller` | `app/controllers/<plural>_controller.rb` (index + show) |
| `--public-views` | `app/views/<plural>/` index + show templates |
| `--routes` | `resources :<plural>, param: :slug` in `config/routes.rb` |
| `--root-path` | `/:slug` via `SlugsController` (for types in `root_content_types`) |
| `--page-builder` | `page_builder: true` + `:blocks` field |

`--root-path` and `--routes` are mutually exclusive for the same type.

## Root-path pages (`/:slug`)

Configure which content types are served at the site root:

```ruby
# config/initializers/brawo_cms.rb
BrawoCms.configure do |config|
  config.root_content_types = [:page]
  config.reserved_slugs = %w[admin api rails assets packs up articles products]
end
```

Add the catch-all route **last** in `config/routes.rb`:

```ruby
BrawoCms::Routing.draw_root_route(self)
```

## Slug rules

- **Per content type:** slug unique within the same STI class (`Article` + `Article` → `about-2`)
- **Across types:** same slug allowed (`Page` `about` at `/about` + `Article` `about` at `/articles/about`)
- **Root types:** slugs must not match `reserved_slugs` (route segments like `admin`, `articles`)
- Auto-suffix on collision (`about-2`, `about-3`, …)

