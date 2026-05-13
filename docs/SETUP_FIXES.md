# Setup Issues Fixed

## Issues Encountered

During the initial setup, several issues were encountered and fixed:

### 1. Port Conflict (PostgreSQL)
**Problem**: Port 5432 was already in use on the host machine.

**Solution**: Changed PostgreSQL port mapping in `docker-compose.yml` from `5432:5432` to `5433:5432`.
- The container still uses 5432 internally
- The host accesses it via port 5433
- This avoids conflicts with locally installed PostgreSQL

### 2. Missing config.ru
**Problem**: Rails couldn't start because `config.ru` was missing.

**Solution**: Created `/test/dummy/config.ru` with proper Rack configuration:
```ruby
require_relative "config/environment"
run Rails.application
Rails.application.load_server
```

### 3. Missing Asset Manifest
**Problem**: Sprockets couldn't find `app/assets/config/manifest.js`.

**Solution**: Created `/test/dummy/app/assets/config/manifest.js` with asset pipeline directives:
```javascript
//= link_tree ../images
//= link_directory ../stylesheets .css
//= link_directory ../../../javascript .js
```

### 4. Missing JavaScript Application Entry
**Problem**: Asset pipeline expected an application.js file.

**Solution**: Created `/test/dummy/app/javascript/application.js` as the entry point.

### 5. Invalid Initializer File
**Problem**: `/test/dummy/config/initializers/new_framework_defaults_7_1.rb` had invalid content (`config.load_defaults 7.1` without proper context).

**Solution**: Replaced with proper comment structure explaining the file's purpose.

### 6. Missing Importmap Configuration
**Problem**: Rails 7.1 expects importmap configuration.

**Solution**: Created `/test/dummy/config/importmap.rb` with:
```ruby
pin "application", preload: true
```

### 7. Setup Script Error Handling
**Problem**: Setup script continued even when containers failed to start.

**Solution**: Added `set -e` and error checking in `setup.sh`:
- Exit on any error
- Check if build succeeds
- Check if services start
- Provide helpful error messages

### 8. Engine Route Helpers
**Problem**: Views were using `admin_root_path` but engine routes need to be namespaced.

**Solution**: Updated all view files to use `brawo_cms.admin_root_path` instead of `admin_root_path`.

When mounting a Rails engine, route helpers are namespaced with the engine name:
```erb
<!-- Wrong -->
<%= link_to "Admin", admin_root_path %>

<!-- Correct -->
<%= link_to "Admin", brawo_cms.admin_root_path %>
```

Common engine route helpers:
- `brawo_cms.admin_root_path` - Admin dashboard
- `brawo_cms.admin_contents_path(content_type: :article)` - Content listing
- `brawo_cms.edit_admin_content_path(content, content_type: :article)` - Edit content

### 9. Sprockets Asset Tree Error
**Problem**: Sprockets manifest.js referenced non-existent directories causing "link_tree argument must be a directory" error.

**Solution**: 
- Simplified `manifest.js` to only link existing directories
- Created missing `app/assets/images` directory
- Removed references to non-existent `javascript` directory path

Updated manifest.js:
```javascript
//= link_directory ../stylesheets .css
```

### 10. ApplicationRecord Constant Error
**Problem**: `BrawoCms::Content` inherited from `ApplicationRecord` which doesn't exist in the engine namespace.

**Solution**: Changed inheritance to `ActiveRecord::Base`:
```ruby
class Content < ActiveRecord::Base
```

### 11. Missing Database Table
**Problem**: The `brawo_cms_contents` table didn't exist because migrations weren't run in the dummy app.

**Solution**: 
- Created `test/dummy/db/migrate/` directory
- Copied engine migration to dummy app
- Ran migrations

Commands:
```bash
mkdir -p test/dummy/db/migrate
cp db/migrate/20250103000001_create_brawo_cms_contents.rb test/dummy/db/migrate/
rails db:migrate
```

### 12. Admin Redirect Loop
**Problem**: Admin root route was pointing to `contents#index` which requires a `content_type` parameter, causing an infinite redirect loop when visiting `/admin`.

**Solution**: 
- Created dedicated `DashboardController` with an index action
- Changed admin root route from `contents#index` to `dashboard#index`
- Dashboard shows all content types and provides quick access links
- Fixed `set_content_type` to properly return after redirect

**Files created:**
- `app/controllers/brawo_cms/admin/dashboard_controller.rb`
- `app/views/brawo_cms/admin/dashboard/index.html.erb`

### 13. Content Types Not Loading (Dashboard Empty)
**Problem**: Content types weren't showing in the dashboard because Rails lazy-loads models in development, so Article and Product models were never loaded, and `BrawoCms.content_types` was empty.

**Solution**: Created initializer to eager-load content type models:
```ruby
# test/dummy/config/initializers/brawo_cms.rb
Rails.application.config.to_prepare do
  Dir[Rails.root.join('app/models/**/*.rb')].each do |file|
    require_dependency file
  end
end
```

### 14. Form Fields Not Saving
**Problem**: Form was using `form_with` which creates properly namespaced params, but the helper methods used `*_field_tag` which don't respect form context. Additionally, custom fields need to be extracted and stored in the `fields` JSONB column.

**Solution**: 
- Changed helper methods from `*_field_tag` to form builder methods (`form.text_field`, etc.)
- Updated `content_params` to separate base attributes from custom fields
- Custom fields are now properly stored in the `fields` hash

### 15. Parameter Missing Error on Form Submit
**Problem**: Form submission failed with "param is missing or the value is empty: content". This happened because `form_with(model: content)` was inferring the parameter scope from the STI child class (Article, Product) instead of using "content".

**Solution**: Added explicit `scope: :content` to the form:
```erb
<%= form_with(model: content, scope: :content, ...) do |form| %>
```

This ensures parameters are submitted as `params[:content]` regardless of the actual model class.

## Current Status

✅ All issues resolved!

The application is now running successfully:
- **Database**: PostgreSQL 16 on port 5433
- **Web Server**: Puma on port 3000
- **Ruby**: 3.3.0
- **Rails**: 7.1.6

## How to Start

```bash
./setup.sh
```

Or manually:
```bash
docker-compose up -d
docker-compose exec web bash -c "cd test/dummy && rails db:create db:migrate"
```

## Access Points

- Main site: http://localhost:3000
- Admin panel: http://localhost:3000/admin
- Articles: http://localhost:3000/articles
- Products: http://localhost:3000/products

## Useful Commands

```bash
# View logs
docker-compose logs -f web

# Access Rails console
docker-compose exec web bash -c "cd test/dummy && rails console"

# Restart services
docker-compose restart web

# Stop services
docker-compose down

# View container status
docker-compose ps
```

## Notes

1. PostgreSQL uses port **5433** on the host (not 5432) to avoid conflicts
2. All application files are mounted as volumes, so changes are reflected immediately
3. Database is persisted in a Docker volume (`postgres_data`)
4. The dummy app demonstrates real-world usage of the CMS engine

