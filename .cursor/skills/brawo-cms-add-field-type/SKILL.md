---
name: brawo-cms-add-field-type
description: Add a new Brawo CMS admin field type end-to-end (model class, factory, dummy example, tests). Use when introducing a new field type or `:type` in the DSL.
---

# Add a field type

## Checklist

1. **Class** — `app/models/brawo_cms/fields/<type>_field.rb` subclassing `BrawoCms::Field`.
2. **Factory** — register in `app/models/brawo_cms/field_factory.rb` (map symbol → class).
3. **Implement** — `render_input(form, record)` and `display_value(record)`; use `FieldWrapperHelper` for layout when needed.
4. **Params** — ensure `ParamsBuilder` permits nested params if the field submits structured data (see repeater/blocks).
5. **Dummy** — add the field to an existing type in `test/dummy/app/models/` (prefer `article.rb` or `product.rb`).
6. **Docs** — one line in `docs/content-types.md` field table if user-facing.
7. **Tests** — `bundle exec rspec`; add helper/field unit spec if logic is non-trivial.

## Do not

- Add a host migration for the new field column (JSONB `fields` only).
- Introduce `BrawoCms::ContentType` AR model.
- Embed large HTML strings in the field class if a partial + helper is clearer.

## References

- [docs/development/admin-internals.md](../../../docs/development/admin-internals.md)
- [docs/content-types.md](../../../docs/content-types.md)
