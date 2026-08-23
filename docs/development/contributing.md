# Contributing

Engine development guide. For DSL basics (content types, taxonomies, blocks), see the [user docs](../index.md).

## Project structure

```
brawo/
├── app/
│   ├── assets/stylesheets/brawo_cms/admin.css
│   ├── controllers/brawo_cms/admin/
│   ├── helpers/brawo_cms/admin/
│   ├── models/brawo_cms/
│   └── views/brawo_cms/admin/
├── config/routes.rb
├── db/migrate/
├── lib/brawo_cms/
├── lib/generators/brawo_cms/
├── test/dummy/              # Demo Rails app
├── spec/                    # RSpec (boots test/dummy)
└── openapi/v1/swagger.yaml
```

## Customizing the admin interface

### Custom controllers

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

### Custom views

Override engine views by creating matching files in your app:

```
app/views/brawo_cms/admin/contents/index.html.erb
```

See [admin-internals.md](admin-internals.md) for helpers, partials, CSS, and JS.

## Advanced model patterns

### Custom validations

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

### Custom scopes

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article, # ...

  scope :featured, -> { where("fields->>'featured' = 'true'") }
  scope :by_category, ->(cat) { where("fields->>'category' = ?", cat) }
end
```

### Querying JSONB fields

```ruby
# Find by field value
Article.where("fields->>'author' = ?", "John Doe")

# Use JSONB operators
Article.where("fields @> ?", { category: "tech" }.to_json)

# Order by field
Article.order("fields->>'published_date' DESC")
```

## Testing

See [testing.md](testing.md) for RSpec, the dummy app, migrations sync, and OpenAPI generation.

## Deployment considerations

1. **Database**: Ensure PostgreSQL is used (required for JSONB)
2. **Migrations**: Run `rails db:migrate` to create the contents and taxonomies tables
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

## More documentation

- [index.md](index.md) — dev docs hub
- [testing.md](testing.md) — engine test suite
- [admin-internals.md](admin-internals.md) — admin UI map
- [../architecture.md](../architecture.md) — system architecture
