---
name: brawo-cms-admin-feature
description: Add or change Brawo CMS admin UI (views, partials, helpers, controller actions, CSS). Use for dashboard, CRUD, or shared admin chrome.
---

# Admin feature change

## Checklist

1. **Controller** — `app/controllers/brawo_cms/admin/`; delegate writes to `ContentService` / `TaxonomyService`.
2. **Views** — thin ERB; reuse `shared/_page_header`, `shared/_form_errors`, `shared/_status_badge`.
3. **Helpers** — `FieldsHelper` for field I/O; resource-specific helpers only when needed.
4. **Page builder** — only load `PageBuilderHelper` on actions that need it.
5. **CSS** — new rules in the appropriate file under `app/assets/stylesheets/brawo_cms/admin/`; variables first.
6. **i18n** — `config/locales/brawo.en.yml` for user-visible strings.
7. **Tests** — request spec under `spec/requests/brawo_cms/admin/` for new routes or critical paths.
8. **Run** — `bundle exec rspec`.

## Symmetry

Contents and taxonomies mirror each other — copy the pattern, do not build a generic `ResourceController` unless explicitly requested.

## References

- [docs/admin.md](../../../docs/admin.md)
- [docs/development/admin-internals.md](../../../docs/development/admin-internals.md)
