# Admin internals

Contributor map for the engine admin UI. User-facing overview: [../admin.md](../admin.md).

## Request flow

```
ContentsController / TaxonomiesController
  → ContentService / TaxonomyService (writes)
  → views + helpers
  → FieldFactory → BrawoCms::Fields::*
```

## Helpers

| Module | Role |
|--------|------|
| `ApplicationHelper` | Dates, status labels/options, sidebar active classes, `status_badge_class` |
| `FieldsHelper` | `display_field_value`, `render_field_input` |
| `FieldWrapperHelper` | Bootstrap grid wrappers for field definitions |
| `PageBuilderHelper` | Block editor markup (contents with `page_builder: true` only) |
| `ReorderMenuHelper` | Move up/down controls for repeaters and blocks |

`PageBuilderHelper` is registered on `ContentsController`, not `BaseController`.

## Frontend blocks (host app)

| Module | Role |
|--------|------|
| `BlocksHelper` | `render_blocks` / `render_block` for `:blocks` JSON on public pages |
| `ErbFileRenderer` | Compiles `app/blocks/*/render.html.erb` (do not use `render file:` — paths are outside view load paths) |

See [../blocks.md](../blocks.md).

## Shared partials

`app/views/brawo_cms/admin/shared/`:

- `_form_errors.html.erb` — validation alert (`record`, `error_heading`)
- `_page_header.html.erb` — title + optional `toolbar` HTML
- `_status_badge.html.erb` — status pill
- `_navigation.html.erb`, `_sidebar.html.erb` — chrome

## CSS

Entry manifest: `app/assets/stylesheets/brawo_cms/admin.css` (Sprockets `require` chain).

| File | Contents |
|------|----------|
| `admin/variables.css` | `--brawo-*` design tokens |
| `admin/shell.css` | Navbar, sidebar, main panel |
| `admin/bootstrap_overrides.css` | Scoped `.brawo-admin` Bootstrap tweaks |
| `admin/components.css` | Cards, tables, repeater layout |
| `admin/page_builder.css` | Page builder + outline UI |

New styles: add tokens first, scope under `.brawo-admin`, pick the file by feature area.

## JavaScript

Importmap entry: `brawo_cms/application` (see `config/importmap.rb`).

| Stimulus controller | Purpose |
|---------------------|---------|
| `page-builder` | Block canvas, picker, outline |
| `sortable` | Drag-and-drop ordering (blocks, repeater rows) |
| `repeater` | Add/remove/reindex repeater rows |

Repeater markup sets `data-controller="repeater"` in `RepeaterField#render_input`. No Sprockets repeater script — Stimulus only.

## Mount paths

Engine mounted at `/admin` in the dummy app. Admin routes live under `/admin/admin/...` (engine `namespace :admin` + mount prefix). API: `/admin/api/v1/...`.

Use route helpers (`admin_contents_path`, etc.) inside engine views; from host apps use `brawo_cms.admin_contents_path` when needed ([routes.md](routes.md)).
