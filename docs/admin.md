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

`content_type` / `taxonomy_type` query param selects which type to manage.

## Sidebar

Auto-populated from `BrawoCms.content_types` and `BrawoCms.taxonomy_types`. New model registered at boot → appears in nav after restart.

## Content form

**Base fields:** title, slug, description, status, published_at.

**Custom fields:** rendered dynamically from field definitions via `FieldFactory` → appropriate input widget per type.

Special UIs:
- `:repeater` — add/remove rows, supports nesting
- `:reference` — multi-select from another content type
- `:taxonomy` — dropdown of taxonomy terms
- `:blocks` + `page_builder: true` — visual block editor

## Status workflow

| Status | Meaning |
|--------|---------|
| `draft` | Default, not public |
| `published` | Visible via `.published` scope |
| `archived` | Hidden from public queries |

Set `published_at` when publishing.

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
