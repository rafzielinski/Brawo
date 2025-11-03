<!-- 8575801f-25cb-4bae-869b-8d123e6150f3 1ad69c15-864d-4e2b-aadd-9fd98d86fa70 -->
# Brawo CMS Engine - Incremental Build Plan

## Phase 1: Engine Foundation & Basic Content Type

### Step 1: Initialize Rails Engine

- Create Rails Engine structure: `brawo_cms` engine
- Set up engine skeleton with proper namespacing
- Configure engine to be mountable and isolated
- Add basic gem dependencies (Rails, ActiveRecord, etc.)
- Create initializer for engine configuration

**Files to create:**

- `lib/brawo_cms/engine.rb` - Engine definition
- `lib/brawo_cms.rb` - Module definition
- `brawo_cms.gemspec` - Gem specification
- `config/routes.rb` - Engine routes
- `lib/brawo_cms/railtie.rb` - Railtie for hooks

### Step 2: Content Type Base Model

- Create `BrawoCms::ContentType` model (acts as registry)
- Create `BrawoCms::Content` base model (polymorphic/parent model)
- Implement concern `BrawoCms::ContentTypeable` for user models
- Add methods to register content types dynamically
- Store content type metadata (name, slug, fields definition)

**Files to create:**

- `app/models/brawo_cms/content_type.rb`
- `app/models/brawo_cms/content.rb`
- `app/models/concerns/brawo_cms/content_typeable.rb`

### Step 3: Simple Fields System

- Add JSON column `fields` to content table
- Implement field accessors/methods for reading/writing fields
- Add field validation helpers
- Support basic field types: text, textarea, number, date

**Files to modify:**

- Migration: `db/migrate/xxx_create_brawo_cms_contents.rb`
- `app/models/brawo_cms/content.rb` - Add field methods

### Step 4: Basic Admin Interface

- Create admin namespace in engine routes
- Build admin layout and base controller
- Generate CRUD views for content types
- Auto-generate forms based on field definitions
- Add content listing page with filters

**Files to create:**

- `app/controllers/brawo_cms/admin/base_controller.rb`
- `app/controllers/brawo_cms/admin/contents_controller.rb`
- `app/views/brawo_cms/admin/layouts/admin.html.erb`
- `app/views/brawo_cms/admin/contents/index.html.erb`
- `app/views/brawo_cms/admin/contents/show.html.erb`
- `app/views/brawo_cms/admin/contents/_form.html.erb`
- `app/views/brawo_cms/admin/contents/new.html.erb`
- `app/views/brawo_cms/admin/contents/edit.html.erb`

### Step 5: User Integration & Generator

- Create generator to scaffold user content type
- Generator creates model, migration, and registers with CMS
- Add helper methods for content type registration
- Create example usage in dummy app or README

**Files to create:**

- `lib/generators/brawo_cms/content_type/content_type_generator.rb`
- `lib/generators/brawo_cms/content_type/templates/model.rb`
- `lib/generators/brawo_cms/content_type/templates/migration.rb`
- `lib/brawo_cms/configuration.rb` - Engine configuration

### Step 6: Basic Admin UI Styling

- Add basic CSS framework (Bootstrap or Tailwind)
- Style admin interface minimally
- Add navigation menu
- Responsive layout

**Files to create:**

- `app/assets/stylesheets/brawo_cms/admin.css` or use CSS framework
- `app/views/brawo_cms/admin/shared/_navigation.html.erb`

## Implementation Strategy

1. **Engine Structure**: Use `rails plugin new brawo_cms --mountable` to generate base
2. **Content Type Pattern**: User defines model, includes concern, registers with `BrawoCms::ContentType.register`
3. **Field Storage**: JSON column for flexibility, with helper methods for type-safe access
4. **Admin Auto-generation**: Controller uses reflection to build forms from content type field definitions
5. **Routes**: Mount engine at `/admin` or configurable path

## Next Phases (Future)

- Custom field types with validations
- Taxonomy system (categories, tags)
- Relationships between content types
- User authentication integration
- Content versioning
- Media management
- Permissions/roles

## Key Technical Decisions

- **Storage**: JSON fields for flexibility, can migrate to normalized tables later
- **Content Type Definition**: Ruby DSL in model files (e.g., `content_type :post, fields: [...]`)
- **Admin**: Custom admin UI (no external gems initially) for full control
- **Routing**: Engine routes namespace, admin routes auto-generated

### To-dos

- [ ] Initialize Rails Engine structure with proper namespacing and basic configuration
- [ ] Create ContentType registry model and Content base model with ContentTypeable concern
- [ ] Implement JSON-based fields system with accessor methods and basic field types
- [ ] Build admin namespace with base controller and contents controller for CRUD operations
- [ ] Create auto-generated admin views (index, show, new, edit, form partial) with dynamic form generation
- [ ] Create content type generator to scaffold user models with CMS integration
- [ ] Add basic admin UI styling and navigation