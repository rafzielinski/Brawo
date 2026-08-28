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
| `status` | `draft` / `published` / `archived` |
| `published_at` | Publish timestamp |
| `fields` | JSONB — all custom fields |

Use custom fields (e.g. `:textarea` for a summary) for type-specific content like excerpts or descriptions.

Base attributes `title`, `slug`, `status`, and `published_at` render in a header card at the top of the admin content form. Additional fields can be placed in that same card via `header_fields` (see below).

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
| `:media` | `accept: "image/*"` (MIME filter) | media library id (integer) |
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
  header_fields: [              # optional — extra fields in the header card
    { name: :hero_tagline, type: :string, label: "Tagline" }
  ],
  fields: [...],                 # flat fields when tabs are not used
  tabs: [                        # tabbed fields — put main fields in a Content tab
    { key: :content, fields: [...] },
    { seo: true },
    { key: :settings, label: "Settings", fields: [...] }
  ]
```

`header_fields` use the same field definition format as `fields`. They render inside the header card alongside title, slug, status, and published date. Values are stored in JSONB `fields` like regular custom fields.

### Field tabs

- **`fields` only** — flat field list in a card, no tab bar
- **`tabs`** — tab bar always shows. Put main fields in a `{ key: :content, fields: [...] }` tab (label defaults to `"Content"`; override with `label:`)
- **`fields` + `tabs`** — still supported: top-level `fields` render in a separate card above tabs. Prefer the Content tab convention instead
- **`{ seo: true }`** inside `tabs:` — built-in SEO tab. Override with `{ seo: true, label: "Search", fields: [...] }`
- **Custom tabs** — `{ key:, label:, fields: }`. Reserved: use `{ seo: true }` for SEO, not `key: :seo`

```ruby
# Flat fields
content_type :note, fields: [...]

# Content + SEO tabs (preferred when using tabs)
content_type :article,
  tabs: [
    { key: :content, fields: [...] },
    { seo: true }
  ]

# Multiple tabs
content_type :product,
  tabs: [
    { key: :content, label: "Product Details", fields: [...] },
    { key: :settings, label: "Settings", fields: [...] }
  ]
```

Default SEO tab fields (stored in JSONB `fields`):

| Field | Type |
|-------|------|
| `meta_title` | `:string` |
| `meta_description` | `:textarea` |
| `og_image` | `:media` |
| `canonical_url` | `:url` |
| `noindex` | `:boolean` |

## Full example

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: "Article",
    tabs: [
      { key: :content, fields: [
        { name: :author, type: :string, label: "Author" },
        { name: :body, type: :textarea, label: "Body" },
        { name: :featured, type: :boolean, label: "Featured" },
        { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: "Category" },
        { name: :related_products, type: :reference, model_class: "Product", label: "Related" },
        { name: :faq_items, type: :repeater, label: "FAQ", sub_fields: [
          { name: :question, type: :string },
          { name: :answer, type: :textarea }
        ]}
      ]},
      { seo: true }
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

