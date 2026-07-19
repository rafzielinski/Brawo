# API

JSON REST API under engine mount. Same services as admin.

Base path: `/admin/api/v1` (relative to mount).

## Auth

Optional bearer token. Set in host app:

```ruby
BrawoCms.api_token = ENV["BRAWOCMS_API_TOKEN"]
```

Send: `Authorization: Bearer <token>`

## Endpoints

### Schema introspection

```
GET /content_types          # all content type schemas
GET /content_types/:type    # single schema (e.g. article)
GET /taxonomy_types         # all taxonomy type schemas
GET /taxonomy_types/:type   # single schema (e.g. category)
```

### Content CRUD

```
GET    /contents?content_type=article
GET    /contents/:id?content_type=article
POST   /contents?content_type=article
PATCH  /contents/:id?content_type=article
DELETE /contents/:id?content_type=article
```

### Taxonomy CRUD

```
GET    /taxonomies?taxonomy_type=category
GET    /taxonomies/:id?taxonomy_type=category
POST   /taxonomies?taxonomy_type=category
PATCH  /taxonomies/:id?taxonomy_type=category
DELETE /taxonomies/:id?taxonomy_type=category
```

## Request body (content)

```json
{
  "content": {
    "title": "My Article",
    "slug": "my-article",
    "status": "published",
    "fields": {
      "author": "Jane",
      "body": "Hello world",
      "category_id": 1,
      "faq_items": [{ "question": "Q?", "answer": "A." }]
    }
  }
}
```

`ParamsBuilder` splits base attrs from `fields` — same as admin forms.

## Response shape

Content:

```json
{
  "id": 1,
  "content_type": "article",
  "title": "My Article",
  "slug": "my-article",
  "status": "published",
  "fields": { "author": "Jane", "body": "..." },
  "created_at": "...",
  "updated_at": "..."
}
```

## OpenAPI

- Swagger UI: `/admin/api/docs`
- Spec: `openapi/v1/swagger.yaml`
- Regenerate: `bundle exec rake openapi:generate`
