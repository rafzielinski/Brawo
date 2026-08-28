# Admin

Bootstrap 5 admin UI mounted with the engine. Auto-generated from registered content/taxonomy types.

## Routes

Engine mounted at `/admin` in host app:

| URL | Purpose |
|-----|---------|
| `/admin` | Dashboard — cards per content type |
| `/admin/contents?content_type=article` | Content list |
| `/admin/contents/new?content_type=article` | Create |
| `/admin/contents/:id?content_type=article` | Show / edit / delete |
| `/admin/taxonomies?taxonomy_type=category` | Taxonomy CRUD |
| `/admin/media` | Media library |

`content_type` / `taxonomy_type` query param selects which type to manage.

## Sidebar

Auto-populated from `BrawoCms.content_types` and `BrawoCms.taxonomy_types`. New model registered at boot → appears in nav after restart.

## Content form

**Base fields:** title, slug, status (`draft` / `published` / `archived`), and `published_at` appear in a header card at the top of the form. Type-specific fields from the DSL render below in tabs when more than one tab is configured.

**Header fields:** optional per-type fields (`header_fields` in the DSL) render in that same header card — see [content-types.md](content-types.md).

**Field tabs:** use `tabs:` for tabbed fields. Put main fields in `{ key: :content, fields: [...] }`. With only `fields:`, the form renders a single card. Add `{ seo: true }` inside `tabs:` for the built-in SEO tab.

**Fields:** rendered dynamically from field definitions via `FieldFactory` → appropriate input widget per type.

Special UIs:
- `:repeater` — add/remove rows, supports nesting
- `:reference` — multi-select from another content type
- `:taxonomy` — dropdown of taxonomy terms
- `:blocks` + `page_builder: true` — visual block editor

## Media library

Central file storage at `/admin/media` (sidebar **Media Library**). Upload images or documents once, reuse via `:media` fields.

- **Admin:** `/admin/media` — grid, upload, edit title/alt text, delete
- **API:** `/admin/api/v1/media` — same CRUD + `accept` and `q` filters on index
- **Field:** `{ name: :hero_image, type: :media, accept: "image/*" }` stores a single media id in JSONB

Host apps must run engine migrations (includes ActiveStorage tables). Configure `config/storage.yml` for production (e.g. S3). Image thumbnails require the `image_processing` gem and libvips or ImageMagick on the host.

## Status workflow

| Status | Meaning |
|--------|---------|
| `draft` | Default, not public |
| `published` | Visible via `.published` scope |
| `archived` | Hidden from public queries |

Set `status` to `published` for public visibility. Set `published_at` in the admin form to record when content was published.

## Layout & assets

- Layout: `app/views/layouts/brawo_cms/admin/application.html.erb`
- CSS: `brawo_cms/admin`
- JS: Stimulus via importmap (`page_builder`, `sortable`, `repeater`)
- Locales: `config/locales/brawo.en.yml`

## Customization

Override engine views in host app:

```
app/views/brawo_cms/admin/contents/_form.html.erb
```

Controllers are thin — business logic in `ContentService` / `TaxonomyService`. Shared by admin and API.
