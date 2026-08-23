---
name: brawo-cms-api-change
description: Change Brawo CMS JSON API (controllers, serializers, OpenAPI). Use when modifying /admin/api/v1 endpoints or response shapes.
---

# API change

## Checklist

1. **Controller** — `app/controllers/brawo_cms/api/v1/`; use services, return consistent error codes via `ServiceResult`.
2. **Serializer** — `app/serializers/brawo_cms/`; keep in sync with OpenAPI schemas in `spec/swagger_helper.rb`.
3. **Request spec** — `spec/requests/brawo_cms/api/v1/<resource>_spec.rb` with rswag `path` blocks and `run_test!`.
4. **Auth** — specs set `BrawoCms.api_token` as needed; see existing `auth_spec.rb`.
5. **Dummy data** — use `ApiTestData.slug(...)` for unique slugs; types from dummy models (`Article`, `Category`).
6. **Regenerate** — `bundle exec rake openapi:generate` after schema changes.
7. **Run** — `bundle exec rspec`.

## Do not

- Bypass services for persistence from API controllers.
- Document endpoints only in YAML without a passing request spec.

## References

- Swagger UI at `/admin/api/docs` and `openapi/v1/swagger.yaml`
- [docs/architecture.md](../../../docs/architecture.md)
- [docs/development/testing.md](../../../docs/development/testing.md)
