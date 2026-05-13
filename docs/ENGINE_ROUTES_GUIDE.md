# Engine Route Helpers Guide

## Understanding Rails Engine Routes

When you mount a Rails engine in your application, the engine's routes are **namespaced** with the engine name. This is important to understand when linking to engine routes from your main application.

## The Mount Point

In your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount BrawoCms::Engine => "/admin"
end
```

This mounts the BrawoCMS engine at the `/admin` path.

## Using Engine Route Helpers

### ❌ Wrong - This Won't Work

```erb
<%= link_to "Admin", admin_root_path %>
<%= link_to "Articles", admin_contents_path(content_type: :article) %>
```

**Error**: `undefined local variable or method 'admin_root_path'`

### ✅ Correct - Namespace with Engine Name

```erb
<%= link_to "Admin", brawo_cms.admin_root_path %>
<%= link_to "Articles", brawo_cms.admin_contents_path(content_type: :article) %>
```

## Complete List of Engine Routes

### Public Routes (Main App → Engine)

From your main application views, use these helpers:

```erb
<!-- Admin Dashboard -->
<%= link_to "Dashboard", brawo_cms.admin_root_path %>
<!-- URL: /admin -->

<!-- Content Type Listing -->
<%= link_to "Articles", brawo_cms.admin_contents_path(content_type: :article) %>
<!-- URL: /admin/contents?content_type=article -->

<!-- New Content -->
<%= link_to "New Article", brawo_cms.new_admin_content_path(content_type: :article) %>
<!-- URL: /admin/contents/new?content_type=article -->

<!-- Show Content -->
<%= link_to "View", brawo_cms.admin_content_path(@article, content_type: :article) %>
<!-- URL: /admin/contents/1?content_type=article -->

<!-- Edit Content -->
<%= link_to "Edit", brawo_cms.edit_admin_content_path(@article, content_type: :article) %>
<!-- URL: /admin/contents/1/edit?content_type=article -->
```

### Internal Routes (Engine → Engine)

Inside the engine's views (e.g., in admin templates), you don't need the namespace:

```erb
<!-- These work inside engine views -->
<%= link_to "Dashboard", admin_root_path %>
<%= link_to "Articles", admin_contents_path(content_type: :article) %>
```

## Checking Available Routes

To see all available engine routes:

```bash
docker-compose exec web bash -c "cd test/dummy && rails routes -g brawo"
```

Or in Rails console:

```ruby
Rails.application.routes.named_routes.helper_names.grep(/brawo/)
```

## Common Patterns

### Linking from Main App to Admin

```erb
<!-- Home page -->
<%= link_to "Manage Content", brawo_cms.admin_root_path, class: "btn" %>

<!-- Article listing -->
<%= link_to "Edit this article", brawo_cms.edit_admin_content_path(@article, content_type: :article) %>
```

### Linking from Admin to Main App

```erb
<!-- In admin navigation -->
<%= link_to "View Site", main_app.root_path %>
<%= link_to "View Article", main_app.article_path(@article) %>
```

Note: Use `main_app` prefix when linking from engine back to main app.

## URL Helpers in Controllers

### Main App Controllers

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
    # Generate admin edit URL
    @edit_url = brawo_cms.edit_admin_content_path(@article, content_type: :article)
  end
end
```

### Engine Controllers

```ruby
module BrawoCms
  module Admin
    class ContentsController < BaseController
      def update
        # Redirect to main app
        redirect_to main_app.article_path(@content)
      end
    end
  end
end
```

## Testing Routes

### In Rails Console

```ruby
# Access engine routes
app.brawo_cms.admin_root_path
# => "/admin"

app.brawo_cms.admin_contents_path(content_type: :article)
# => "/admin/contents?content_type=article"

# Access main app routes
app.root_path
# => "/"

app.articles_path
# => "/articles"
```

## Summary

| Context | Syntax | Example |
|---------|--------|---------|
| Main App → Engine | `brawo_cms.route_path` | `brawo_cms.admin_root_path` |
| Engine → Main App | `main_app.route_path` | `main_app.root_path` |
| Engine → Engine | `route_path` | `admin_root_path` |
| Main App → Main App | `route_path` | `articles_path` |

## Troubleshooting

### Error: "undefined method `admin_root_path'"

**Fix**: Add `brawo_cms.` prefix:
```erb
<%= link_to "Admin", brawo_cms.admin_root_path %>
```

### Error: "No route matches"

**Fix**: Make sure engine is mounted in `config/routes.rb`:
```ruby
mount BrawoCms::Engine => "/admin"
```

### Wrong URL Generated

**Check**: Verify you're using the correct namespace for your context (main app vs engine).

---

For more information, see:
- [Rails Engines Guide](https://guides.rubyonrails.org/engines.html)
- [Rails Routing Guide](https://guides.rubyonrails.org/routing.html)

