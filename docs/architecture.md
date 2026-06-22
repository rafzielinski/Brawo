# BrawoCMS Architecture

Rails engine mounted at `/admin`. Host app defines content types (`Article`, `Product`) and taxonomies (`Category`). Engine provides admin UI + JSON API. Shared service layer sits between controllers and models.

## Big picture

```mermaid
flowchart TB
  subgraph HostApp["Host app (test/dummy)"]
    Models["Article, Product, Category\n(content_type / taxonomy_type DSL)"]
    Public["ArticlesController, ProductsController\n(public site)"]
  end

  subgraph Config["BrawoCms config"]
    Registry["BrawoCms.content_types\nBrawoCms.taxonomy_types"]
  end

  subgraph Engine["BrawoCms::Engine @ /admin"]
  end

  subgraph Controllers
    Admin["Admin::ContentsController\nAdmin::TaxonomiesController\n(HTML forms)"]
    API["Api::V1::ContentsController\nApi::V1::TaxonomiesController\n(JSON)"]
    Types["Api::V1::ContentTypesController\nApi::V1::TaxonomyTypesController"]
  end

  subgraph Services
    CS["ContentService"]
    TS["TaxonomyService"]
    PB["ParamsBuilder"]
    SR["ServiceResult"]
  end

  subgraph Persistence
    Content["BrawoCms::Content\n(STI, fields JSONB)"]
    Taxonomy["BrawoCms::Taxonomy\n(STI, fields JSONB)"]
  end

  subgraph Presentation
    Fields["FieldFactory + Fields::*\n(admin form widgets)"]
    Serializers["ContentSerializer\nTaxonomySerializer\nTypeSerializer"]
    Views["Admin views + helpers + JS"]
  end

  Models -->|"register on load"| Registry
  Admin --> CS & TS
  API --> CS & TS
  Types --> Registry
  CS & TS --> PB
  CS & TS --> SR
  CS --> Content
  TS --> Taxonomy
  Registry --> CS & TS
  Admin --> Views
  Views --> Fields
  API --> Serializers
  Public --> Models
  Models --> Content
```

## Layer responsibilities

| Layer | Where | Does what |
|---|---|---|
| **Config registry** | `lib/brawo_cms.rb` | Global map of registered types → model class, field defs, labels |
| **Host models** | e.g. `Article`, `Category` | Declare type via `content_type` / `taxonomy_type`; auto-register + define accessors |
| **Base models** | `BrawoCms::Content`, `BrawoCms::Taxonomy` | STI on shared tables; core cols (`title`, `slug`, `status`); custom fields in `fields` JSONB |
| **Concerns** | `ContentTypeable`, `TaxonomyTypeable` | Wire model → registry; `default_scope` by `type`; dynamic field accessors |
| **Field system** | `FieldFactory`, `Fields::*` | Turn field defs into admin inputs (text, taxonomy picker, repeater, etc.) |
| **Services** | `ContentService`, `TaxonomyService` | CRUD logic; lookup type config; return `ServiceResult` |
| **ParamsBuilder** | `app/services/brawo_cms/params_builder.rb` | Normalize request params → `{ title:, slug:, fields: {...} }`; handles repeaters |
| **ServiceResult** | `app/services/brawo_cms/service_result.rb` | Uniform success/failure envelope for controllers |
| **Admin controllers** | `Admin::ContentsController` etc. | HTTP/HTML; call services; redirect or re-render forms |
| **API controllers** | `Api::V1::*` | HTTP/JSON; bearer token auth; call same services |
| **Serializers** | `ContentSerializer`, etc. | Shape records → JSON for API only |
| **Public controllers** | host app | Read published content for frontend; bypass engine services |

## Content type registration flow

```mermaid
sequenceDiagram
  participant Article as Article model
  participant Concern as ContentTypeable
  participant Registry as BrawoCms.content_types
  participant Content as BrawoCms::Content

  Article->>Concern: content_type :article, fields: [...]
  Concern->>Registry: register_content_type(:article, Article, ...)
  Concern->>Content: define_field_accessors(fields)
  Concern->>Article: default_scope where(type: "Article")
```

One table `brawo_cms_contents`, many STI subclasses. Type picked by `?content_type=article` (admin/API) or model class directly (public site).

## Create request flow (admin)

```mermaid
sequenceDiagram
  participant Browser
  participant Admin as Admin::ContentsController
  participant Svc as ContentService
  participant PB as ParamsBuilder
  participant Model as Article

  Browser->>Admin: POST /admin/admin/contents?content_type=article
  Admin->>Svc: type_config(:article)
  Svc->>Registry: lookup config
  Admin->>Svc: build_attributes(params)
  Svc->>PB: from_request(fields, repeaters, etc.)
  PB-->>Admin: { title, slug, fields: {...} }
  Admin->>Svc: create(type:, attributes:)
  Svc->>Model: Article.new(attrs).save
  Svc-->>Admin: ServiceResult
  Admin-->>Browser: redirect or form errors
```

API create path is identical through services — difference is JSON in/out via serializers instead of ERB views.

## Content vs taxonomy — parallel stacks

| | Content | Taxonomy |
|---|---|---|
| Base model | `BrawoCms::Content` | `BrawoCms::Taxonomy` |
| Concern | `ContentTypeable` | `TaxonomyTypeable` |
| Service | `ContentService` | `TaxonomyService` |
| Admin | `Admin::ContentsController` | `Admin::TaxonomiesController` |
| API | `Api::V1::ContentsController` | `Api::V1::TaxonomiesController` |
| Schema API | `ContentTypesController` | `TaxonomyTypesController` |
| Serializer | `ContentSerializer` | `TaxonomySerializer` |

Same pattern both sides. Intentional symmetry.

## Field storage model

```
brawo_cms_contents
├── id, type (STI), title, slug, description, status, published_at  ← columns
└── fields (jsonb)  ← custom per-type fields (author, body, faq_items, ...)
```

Base attrs = table columns. Custom attrs = `fields` hash. `ParamsBuilder` splits incoming params accordingly. `FieldFactory` renders the admin form from type config.

## Routes (mental model)

```
Host app
  /articles          → public Article pages
  /admin             → engine mount point

Engine (under /admin)
  /admin/admin/contents?content_type=article   → admin CRUD
  /admin/api/v1/contents?content_type=article  → JSON API
  /admin/api/v1/content_types                  → schema introspection
```

Double `/admin/admin` = mount prefix + engine `namespace :admin`. Expected.

## Design intent

- **Models** — data + type-specific behavior
- **Registry** — runtime type catalog
- **Fields** — admin UI only
- **Services** — business logic shared by admin + API
- **ParamsBuilder** — param parsing (messiest part, esp. repeaters)
- **Controllers** — thin HTTP adapters
- **Serializers** — API response shape only
