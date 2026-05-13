# Taxonomy Feature

## Overview

The taxonomy feature in BrawoCMS provides a flexible way to create and manage taxonomies (categories, tags, etc.) separately from content types. Taxonomies share similar functionality with content types but are grouped separately in the admin interface.

## Key Features

- **STI-based architecture**: All taxonomy types share a single `brawo_cms_taxonomies` table
- **Custom fields**: Stored in JSONB for flexibility
- **Slug generation**: Automatic slug generation from name
- **Separated UI**: Taxonomies appear in their own section in the admin sidebar
- **Generator support**: Easy creation of new taxonomy types

## Database Schema

```sql
create_table "brawo_cms_taxonomies" do |t|
  t.string :type, null: false
  t.string :name
  t.string :slug
  t.text :description
  t.jsonb :fields, default: {}, null: false
  t.timestamps
end
```

Indexes:
- `type` - for STI filtering
- `slug` - unique index for URL-friendly identifiers
- `fields` - GIN index for fast JSONB queries

## Creating a Taxonomy Type

### Using the Generator

```bash
rails generate brawo_cms:taxonomy_type Category color:string icon:string order:number
```

This creates:
- `app/models/category.rb` with field definitions
- Empty migration (fields stored in JSONB)

### Manual Creation

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { name: :color, type: :string, label: 'Color', help_text: 'Hex color code' },
      { name: :icon, type: :string, label: 'Icon Class' },
      { name: :order, type: :number, label: 'Sort Order' }
    ]
end
```

## Field Types

Taxonomies support the same field types as content types:

- `:string` - Single-line text
- `:textarea` - Multi-line text
- `:number` - Numeric values
- `:date` - Date picker
- `:boolean` - Checkbox
- `:select` - Dropdown with choices
- `:taxonomy` - Reference to another taxonomy (see [TAXONOMY_REFERENCE_GUIDE.md](TAXONOMY_REFERENCE_GUIDE.md))

## Using Taxonomies in Your Application

```ruby
# Create a taxonomy
category = Category.create(
  name: "Technology",
  slug: "tech",
  description: "Technology-related content",
  color: "#3b82f6",
  icon: "fa-laptop",
  order: 1
)

# Query taxonomies
Category.all
Category.find_by(slug: "tech")

# Access custom fields
category.color # => "#3b82f6"
category.icon  # => "fa-laptop"
category.order # => 1
```

## Admin Interface

Taxonomies appear in a separate "TAXONOMIES" section in the admin sidebar. Each taxonomy type has its own:

- Index page with listing
- Create/New form
- Edit form
- Show/Detail page

The admin interface automatically generates forms based on the field definitions.

## Example Use Cases

### Categories

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { name: :color, type: :string, label: 'Color' },
      { name: :parent_id, type: :number, label: 'Parent Category ID' }
    ]
end
```

### Tags

```ruby
class Tag < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :tag,
    label: 'Tag',
    fields: [
      { name: :popularity, type: :number, label: 'Popularity Score' },
      { name: :featured, type: :boolean, label: 'Featured Tag' }
    ]
end
```

### Authors

```ruby
class Author < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :author,
    label: 'Author',
    fields: [
      { name: :bio, type: :textarea, label: 'Biography' },
      { name: :website, type: :string, label: 'Website URL' },
      { name: :twitter, type: :string, label: 'Twitter Handle' }
    ]
end
```

## Associating Taxonomies with Content

You can associate taxonomies with content types using the `:taxonomy` field type:

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' },
      { name: :author_id, type: :taxonomy, taxonomy_type: :author, label: 'Author' }
    ]
end
```

The admin interface will automatically:
- Display a dropdown with all available taxonomy entries
- Store the selected taxonomy ID
- Show the taxonomy name when viewing content

For complete documentation on taxonomy references, see [TAXONOMY_REFERENCE_GUIDE.md](TAXONOMY_REFERENCE_GUIDE.md).

Then in your application:

```ruby
article = Article.find(params[:id])

# Get the taxonomy IDs
category_id = article.category_id
author_id = article.author_id

# Look up the taxonomy entries
category = Category.find(category_id) if category_id
author = Author.find(author_id) if author_id

# Display
puts "#{article.title} by #{author&.name} in #{category&.name}"
```

## Pages Configuration

Both taxonomy types and content types support an optional `pages` configuration:

```ruby
taxonomy_type :category,
  label: 'Category',
  pages: true, # Enable page generation
  fields: [...]
```

This is stored in the registry and can be used by your application to determine whether to generate public-facing pages for the taxonomy.

## API

### BrawoCms Module

```ruby
# Register a taxonomy type
BrawoCms.register_taxonomy_type(:category, Category, options)

# Access all taxonomy types
BrawoCms.taxonomy_types
# => { category: { class: Category, fields: [...], label: 'Category', pages: true } }

# Access specific taxonomy type
BrawoCms.taxonomy_types[:category]
```

### Taxonomy Model

```ruby
taxonomy = Category.new(name: "Tech")

# Field accessors
taxonomy.get_field(:color)
taxonomy.set_field(:color, "#ff0000")
taxonomy.field_value(:color)

# Metadata
taxonomy.taxonomy_type_name    # => "category"
taxonomy.taxonomy_type_config  # => { class: Category, fields: [...], ... }
taxonomy.field_definitions     # => [{ name: :color, type: :string, ... }]

# Slug generation
taxonomy.name = "My Category"
taxonomy.save
taxonomy.slug # => "my-category"
```

## Routes

Taxonomy routes are automatically added to the engine:

```ruby
BrawoCms::Engine.routes.draw do
  namespace :admin do
    resources :taxonomies
  end
end
```

Access via:
- `admin_taxonomies_path(taxonomy_type: :category)`
- `new_admin_taxonomy_path(taxonomy_type: :category)`
- `edit_admin_taxonomy_path(taxonomy, taxonomy_type: :category)`
- `admin_taxonomy_path(taxonomy, taxonomy_type: :category)`

## Differences from Content Types

| Feature | Content Types | Taxonomy Types |
|---------|--------------|----------------|
| Base class | `BrawoCms::Content` | `BrawoCms::Taxonomy` |
| Table | `brawo_cms_contents` | `brawo_cms_taxonomies` |
| Name field | `title` | `name` |
| Status field | Yes (draft/published/archived) | No |
| Published_at | Yes | No |
| Admin section | Content Types | Taxonomies |
| Use case | Main content items | Categories, tags, authors |

## Best Practices

1. **Use taxonomies for organizational structures**: Categories, tags, authors, locations
2. **Use content types for actual content**: Articles, products, pages
3. **Keep taxonomy fields simple**: Focus on metadata that helps organize content
4. **Use slugs for URLs**: They're automatically generated and indexed
5. **Consider hierarchy**: Use fields like `parent_id` for nested taxonomies

## Migration Guide

If you're upgrading from an older version:

1. Run the migration:
```bash
rails db:migrate
```

2. Convert existing taxonomy models to use `BrawoCms::Taxonomy`:
```ruby
# Before
class Category < ApplicationRecord
end

# After
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable
  
  taxonomy_type :category, ...
end
```

3. Update your admin navigation to include taxonomies
4. Update any references from `title` to `name` for taxonomies

