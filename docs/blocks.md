# Blocks

## What are blocks?

Blocks are composable page sections — headings, text, FAQs, heroes, etc. — stored as JSON in a content type's `:blocks` field. Enable the visual page builder in admin; render blocks on your public site via a helper.

Blocks require a content type with a `:blocks` field. See [Content types](content-types.md) for the base setup.

## Create your first block-enabled page type

### 1. Define a content type with blocks

```ruby
class Page < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :page,
    label: "Page",
    page_builder: true,
    fields: [
      { name: :blocks, type: :blocks, label: "Page Content" }
    ]
end
```

`page_builder: true` switches the admin form to drag-and-drop block editor.

### 2. Create a page in admin

Go to `/admin/contents?content_type=page`, add blocks via the sidebar picker, save.

### 3. Render on the frontend

```erb
<%= render_blocks(@page.blocks) %>
```

## Storage format

```json
[
  { "type": "heading", "data": { "text": "Hello", "level": 2 } },
  { "type": "text", "data": { "body": "Paragraph here." } },
  { "type": "faq", "data": { "section_title": "FAQ", "items": [{ "question": "...", "answer": "..." }] } }
]
```

## Built-in blocks

| Block | Fields |
|-------|--------|
| `heading` | `text` (string, required), `level` (select: H1/H2/H3) |
| `text` | `body` (textarea) |
| `faq` | `section_title` (string), `items` (repeater: question/answer) |

Files: `app/blocks/<name>/block.rb` + `render.html.erb`.

## Create a custom block

### 1. Add block files

```
app/blocks/hero/
  block.rb
  render.html.erb
```

### 2. Define fields

```ruby
# app/blocks/hero/block.rb
label "Hero"

field :title, type: :string, label: "Title", required: true,
  wrapper: { width: "50", class: "hero-title" }
field :subtitle, type: :textarea, label: "Subtitle",
  wrapper: { width: "50" }
field :cta_url, type: :string, label: "CTA URL"
```

### 3. Add a render template

```erb
<%# app/blocks/hero/render.html.erb %>
<section class="hero">
  <h1><%= data[:title] %></h1>
  <p><%= data[:subtitle] %></p>
  <% if data[:cta_url].present? %>
    <a href="<%= data[:cta_url] %>">Learn more</a>
  <% end %>
</section>
```

Blocks auto-discovered from engine `app/blocks/` and host `app/blocks/` on boot. Restart after adding a new block.

## Filter blocks per content type

```ruby
content_type :landing,
  allowed_blocks: [:heading, :text, :hero],
  # or
  excluded_blocks: [:faq],
  fields: [{ name: :blocks, type: :blocks }]
```

## Render on frontend

```erb
<%= render_blocks(@page.blocks) %>
```

`BlocksHelper` renders each block's `render.html.erb` with a `data` local (ERB files under `app/blocks/` are compiled via `ErbFileRenderer`, not `render file:`).

Single block: `<%= render_block({ type: "heading", data: { text: "Hi", level: 1 } }) %>`

## Admin UI

- Stimulus controllers: `page_builder`, `sortable`, `repeater`
- Add/remove/reorder blocks via sidebar picker
- Field inputs auto-built from block field definitions (no custom admin template needed)
