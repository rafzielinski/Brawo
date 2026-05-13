# BrawoCMS Development Guide

## Project Structure

```
brawo/
├── app/
│   ├── assets/stylesheets/
│   │   └── brawo_cms/admin.css        # Admin UI styles
│   ├── controllers/
│   │   └── brawo_cms/admin/
│   │       ├── base_controller.rb      # Base admin controller
│   │       └── contents_controller.rb  # CRUD controller
│   ├── helpers/
│   │   └── brawo_cms/admin/
│   │       └── contents_helper.rb      # View helpers
│   ├── models/
│   │   ├── brawo_cms/
│   │   │   └── content.rb             # Base content model
│   │   └── concerns/brawo_cms/
│   │       └── content_typeable.rb    # Content type concern
│   └── views/
│       ├── layouts/brawo_cms/admin/
│       │   └── application.html.erb   # Admin layout
│       └── brawo_cms/admin/
│           ├── contents/              # Admin CRUD views
│           └── shared/                # Shared partials
├── config/
│   └── routes.rb                      # Engine routes
├── db/
│   └── migrate/
│       └── 20250103000001_create_brawo_cms_contents.rb
├── lib/
│   ├── brawo_cms/
│   │   ├── engine.rb                  # Engine definition
│   │   └── version.rb                 # Version
│   ├── brawo_cms.rb                   # Main module
│   └── generators/
│       └── brawo_cms/content_type/    # Content type generator
├── test/
│   └── dummy/                         # Demo Rails app
│       ├── app/
│       │   ├── controllers/
│       │   │   ├── articles_controller.rb
│       │   │   ├── products_controller.rb
│       │   │   └── pages_controller.rb
│       │   ├── models/
│       │   │   ├── article.rb         # Example content type
│       │   │   └── product.rb         # Example content type
│       │   └── views/
│       │       ├── articles/
│       │       ├── products/
│       │       └── pages/
│       └── config/
│           ├── database.yml
│           └── routes.rb
├── Dockerfile
├── docker-compose.yml
├── Gemfile
├── brawo_cms.gemspec
└── README.md
```

## Core Concepts

### 1. Content Model (STI)

All content types inherit from `BrawoCms::Content` and share a single table:

- Uses Single Table Inheritance (STI) with `type` column
- Custom fields stored in JSONB `fields` column
- Built-in fields: title, slug, description, status, published_at
- Automatic slug generation from title

### 2. ContentTypeable Concern

The `ContentTypeable` concern provides:

- `content_type` DSL method for defining content types
- Automatic field accessor methods
- Registration with the BrawoCMS engine
- Default scope filtering by type

### 3. Field System

Fields are defined as hashes with:
- `name`: Field identifier (symbol)
- `type`: Field type (string, textarea, number, date, boolean, select)
- `label`: Human-readable label
- `help_text`: Optional help text
- `choices`: Array for select fields

### 4. Admin Interface

The admin interface is auto-generated based on content type definitions:

- Dynamic form generation
- Automatic routing
- CRUD operations
- Content status management

## Creating New Content Types

### Using the Generator

```bash
rails generate brawo_cms:content_type Event name:string location:string event_date:date
```

This creates:
- `app/models/event.rb` with field definitions
- Empty migration (fields stored in JSON)

### Manual Creation

```ruby
class Page < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :page,
    label: 'Page',
    fields: [
      { name: :body, type: :textarea, label: 'Page Content' },
      { name: :template, type: :select, label: 'Template',
        choices: [['Default', 'default'], ['Full Width', 'full_width']] },
      { name: :show_in_menu, type: :boolean, label: 'Show in Menu' }
    ]
end
```

## Customizing the Admin Interface

### Custom Controllers

Inherit from `BrawoCms::Admin::BaseController`:

```ruby
module BrawoCms
  module Admin
    class CustomController < BaseController
      def custom_action
        # your code
      end
    end
  end
end
```

### Custom Views

Override engine views by creating matching files in your app:

```
app/views/brawo_cms/admin/contents/index.html.erb
```

## Advanced Usage

### Custom Validations

Add validations to your content type models:

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article, # ...

  validates :author, presence: true
  validate :published_date_in_past

  private

  def published_date_in_past
    if published_date.present? && Date.parse(published_date) > Date.today
      errors.add(:published_date, "can't be in the future")
    end
  end
end
```

### Custom Scopes

Add scopes to filter content:

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article, # ...

  scope :featured, -> { where("fields->>'featured' = 'true'") }
  scope :by_category, ->(cat) { where("fields->>'category' = ?", cat) }
end
```

### Querying JSONB Fields

```ruby
# Find by field value
Article.where("fields->>'author' = ?", "John Doe")

# Use JSONB operators
Article.where("fields @> ?", { category: "tech" }.to_json)

# Order by field
Article.order("fields->>'published_date' DESC")
```

## Testing

Add tests for your content types:

```ruby
require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test "should create article with custom fields" do
    article = Article.create!(
      title: "Test Article",
      author: "Test Author",
      body: "Test content"
    )
    
    assert_equal "Test Author", article.author
    assert_equal "Test content", article.body
  end
end
```

## Deployment Considerations

1. **Database**: Ensure PostgreSQL is used (required for JSONB)
2. **Migrations**: Run `rails db:migrate` to create the contents table
3. **Assets**: Precompile assets including engine stylesheets
4. **Environment**: Set appropriate database credentials

## Troubleshooting

### Fields not saving
- Check field definitions match form inputs
- Verify field names in permitted params

### Admin interface not loading
- Ensure engine is mounted in routes
- Check asset pipeline includes engine assets

### Content type not appearing
- Verify model includes `ContentTypeable`
- Check `content_type` is called with proper syntax
- Restart server to reload model definitions

## Future Development Ideas

- Add rich text editor support
- Implement media library
- Add content versioning
- Create API endpoints
- Build taxonomy system
- Add user roles and permissions

