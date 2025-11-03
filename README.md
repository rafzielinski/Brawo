# BrawoCMS

A flexible, developer-friendly CMS engine for Rails applications. BrawoCMS allows you to create custom content types and taxonomies with dynamic fields using a simple Ruby DSL.

## Features

- 🚀 **Easy Setup**: Mount as a Rails engine and start creating content types immediately
- 📝 **Dynamic Fields**: JSON-based field storage with support for text, textarea, number, date, boolean, and select fields
- 🏷️ **Taxonomy Support**: Built-in support for categories, tags, and other organizational structures
- 🎨 **Auto-generated Admin UI**: Beautiful Bootstrap-based admin interface with automatic form generation
- 🔧 **Generators**: Scaffold new content types and taxonomies with a single command
- 📦 **STI-based Architecture**: All content types and taxonomies share tables using Single Table Inheritance
- 🐳 **Docker Ready**: Includes Docker configuration for development

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brawo_cms'
```

And then execute:
```bash
$ bundle install
```

## Quick Start with Docker

1. Clone the repository and build the Docker containers:

```bash
docker-compose build
docker-compose up
```

2. In a new terminal, run the database migrations:

```bash
docker-compose exec web bash
cd test/dummy
rails db:create db:migrate
```

3. Visit http://localhost:3000 to see the demo app
4. Visit http://localhost:3000/admin to access the CMS admin panel

## Usage

### 1. Mount the Engine

Add to your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  mount BrawoCms::Engine => "/admin"
  # your other routes...
end
```

### 2. Create a Content Type

#### Option A: Using the Generator

```bash
rails generate brawo_cms:content_type Article author:string body:textarea published_date:date
```

#### Option B: Manual Creation

Create a model that inherits from `BrawoCms::Content`:

```ruby
# app/models/article.rb
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :author, type: :string, label: 'Author', help_text: 'Article author name' },
      { name: :body, type: :textarea, label: 'Article Body' },
      { name: :published_date, type: :date, label: 'Publish Date' },
      { name: :featured, type: :boolean, label: 'Featured Article' },
      { name: :category, type: :select, label: 'Category', 
        choices: [['Technology', 'tech'], ['Business', 'business'], ['Lifestyle', 'lifestyle']] }
    ]
end
```

### 3. Available Field Types

- `:string` - Single line text input
- `:textarea` - Multi-line text input
- `:number` / `:integer` - Numeric input
- `:date` - Date picker
- `:datetime` - Date and time picker
- `:boolean` / `:checkbox` - Checkbox
- `:select` - Dropdown with predefined choices
- `:taxonomy` - Reference to taxonomy entries (see below)

### 4. Accessing Content in Your App

```ruby
# In your controller
class ArticlesController < ApplicationController
  def index
    @articles = Article.published.order(created_at: :desc)
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

```erb
<!-- In your view -->
<h1><%= @article.title %></h1>
<p>By <%= @article.author %></p>
<div><%= @article.body %></div>
```

### 5. Content Scopes

Built-in scopes:
- `published` - Only published content
- `draft` - Only draft content
- `archived` - Only archived content

### 6. Admin Interface

Once mounted, the admin interface is available at `/admin` (or your custom mount point).

Features:
- List all content types in the sidebar
- Create, edit, delete content
- Dynamic form generation based on field definitions
- Status management (draft, published, archived)
- Automatic slug generation from titles

## Example Content Types

## Taxonomies

BrawoCMS includes built-in support for taxonomies (categories, tags, authors, etc.) that are managed separately from content types in the admin interface.

### Creating a Taxonomy Type

#### Using the Generator

```bash
rails generate brawo_cms:taxonomy_type Category color:string icon:string order:number
```

#### Manual Creation

```ruby
# app/models/category.rb
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

### Using Taxonomies

```ruby
# Create a taxonomy
category = Category.create(
  name: "Technology",
  slug: "tech",
  description: "Technology-related content",
  color: "#3b82f6"
)

# Query taxonomies
Category.all
Category.find_by(slug: "tech")

# Access custom fields
category.color # => "#3b82f6"
```

### Referencing Taxonomies in Content

Use the `:taxonomy` field type to create references to taxonomy entries:

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' }
    ]
end
```

The admin will automatically show a dropdown with all available taxonomy entries. See [TAXONOMY_REFERENCE_GUIDE.md](TAXONOMY_REFERENCE_GUIDE.md) for details.

For more details, see [TAXONOMY_GUIDE.md](TAXONOMY_GUIDE.md).

## Example Content Types

### Blog Post

```ruby
class Post < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :post,
    label: 'Blog Post',
    fields: [
      { name: :author, type: :string, label: 'Author' },
      { name: :body, type: :textarea, label: 'Content' },
      { name: :published_at, type: :datetime, label: 'Publish Date' },
      { name: :featured_image_url, type: :string, label: 'Featured Image URL' }
    ]
end
```

### Product Catalog

```ruby
class Product < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :product,
    label: 'Product',
    fields: [
      { name: :price, type: :number, label: 'Price' },
      { name: :sku, type: :string, label: 'SKU' },
      { name: :stock_quantity, type: :integer, label: 'Stock' },
      { name: :description, type: :textarea, label: 'Description' },
      { name: :availability, type: :select, label: 'Availability',
        choices: [['In Stock', 'in_stock'], ['Out of Stock', 'out_of_stock']] }
    ]
end
```

## Architecture

### Single Table Inheritance (STI)

All content types inherit from `BrawoCms::Content` and share the `brawo_cms_contents` table:

- `type` - Stores the class name (Article, Product, etc.)
- `title` - Content title
- `slug` - URL-friendly identifier (auto-generated)
- `description` - Short description
- `fields` - JSONB column storing custom field data
- `status` - draft, published, or archived
- `published_at` - Timestamp for publishing

### Field Storage

Custom fields are stored in a JSONB column, providing:
- Flexibility to add/remove fields without migrations
- Fast queries using GIN indexes
- Type-safe accessors via field definitions

## Development

### Running Tests

```bash
docker-compose exec web bash
cd test/dummy
rails test
```

### Accessing the Dummy App

The `test/dummy` directory contains a full Rails application demonstrating BrawoCMS usage with Article and Product content types.

## Future Enhancements

Planned features for future releases:

- Media management and file uploads
- Content versioning and revision history
- Content relationships
- User authentication and permissions
- Custom validations for field types
- API endpoints for headless CMS usage
- Search and filtering

## Contributing

Bug reports and pull requests are welcome on GitHub.

## License

The gem is available as open source under the terms of the MIT License.

## Credits

Built with ❤️ by the BrawoCMS team

