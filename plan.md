# Brawo CMS - Component-Based Architecture Plan

## Core Philosophy

**Everything related to a content type lives in ONE file.**

Each content type is a self-contained component with its configuration, fields, validations, and custom methods. The gem handles all the heavy lifting (tables, routes, migrations) invisibly in the background.

---

## Architecture Overview

### Gem: `brawo` (hidden complexity)
- Table generation (invisible to user)
- Route registration (automatic)
- Base content type class
- Field type definitions
- Admin interface
- Core services

### Host App: `app/content_types/` (user territory)
```
app/
├── content_types/
│   ├── blog_post_type.rb          # Everything about blog posts
│   ├── product_type.rb            # Everything about products
│   ├── team_member_type.rb        # Everything about team members
│   └── landing_page_type.rb       # Everything about landing pages
└── controllers/
    └── content_types/             # Optional: custom controllers per type
        ├── blog_posts_controller.rb
        └── products_controller.rb
```

**User never sees**: migrations, route definitions, model boilerplate, table schemas

---

## Part 1: Content Type Component Pattern

### Basic Content Type Definition

```ruby
# app/content_types/blog_post_type.rb
class BlogPostType < Brawo::ContentType
  # Metadata
  configure do |c|
    c.name = "Blog Post"
    c.slug = "blog"
    c.icon = "newspaper"
    c.description = "Articles and blog content"
  end
  
  # Routing (gem auto-generates actual routes)
  routes do
    archive "/blog"
    single "/blog/:slug"
  end
  
  # Field definitions (gem auto-generates table columns)
  fields do
    field :title, :string, required: true
    field :subtitle, :string
    field :content, :rich_text, required: true
    field :excerpt, :text
    field :reading_time, :integer
    field :featured, :boolean, default: false
    field :category, :select, choices: ['Technology', 'Design', 'Business']
    field :tags, :array, of: :string
    field :published_at, :datetime
    field :author, :belongs_to, class_name: 'User'
    field :featured_image, :image
  end
  
  # Validations
  validates :reading_time, numericality: { greater_than: 0 }, allow_nil: true
  validates :category, presence: true
  
  # Scopes
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :recent, -> { order(published_at: :desc).limit(10) }
  
  # Custom methods (available on all blog post instances)
  def reading_time_text
    "#{reading_time} min read"
  end
  
  def has_tags?
    tags.present? && tags.any?
  end
  
  def related_posts(limit = 3)
    self.class.where(category: category)
              .where.not(id: id)
              .published
              .limit(limit)
  end
  
  # Callbacks
  before_save :calculate_reading_time
  after_publish :notify_subscribers
  
  private
  
  def calculate_reading_time
    return unless content.present?
    word_count = content.to_plain_text.split.size
    self.reading_time = (word_count / 200.0).ceil
  end
  
  def notify_subscribers
    # Custom logic here
  end
end
```

### Advanced Content Type with Relationships

```ruby
# app/content_types/product_type.rb
class ProductType < Brawo::ContentType
  configure do |c|
    c.name = "Product"
    c.slug = "products"
    c.icon = "shopping-cart"
  end
  
  routes do
    archive "/shop"
    single "/shop/:slug"
  end
  
  fields do
    field :name, :string, required: true
    field :description, :text
    field :price, :decimal, precision: 10, scale: 2, required: true
    field :compare_at_price, :decimal, precision: 10, scale: 2
    field :sku, :string, unique: true, required: true
    field :stock_quantity, :integer, default: 0
    field :weight, :decimal
    field :dimensions, :json
    field :product_images, :images, multiple: true
    field :vendor, :belongs_to, class_name: 'Vendor'
    field :categories, :has_many, through: :product_categories
  end
  
  # Virtual attributes
  def on_sale?
    compare_at_price.present? && compare_at_price > price
  end
  
  def discount_percentage
    return 0 unless on_sale?
    ((compare_at_price - price) / compare_at_price * 100).round
  end
  
  def in_stock?
    stock_quantity > 0
  end
  
  def formatted_price
    "$#{price}"
  end
  
  # Class methods
  def self.bestsellers(limit = 10)
    # Assuming you have sales tracking
    joins(:orders).group(:id).order('COUNT(orders.id) DESC').limit(limit)
  end
  
  def self.on_sale
    where.not(compare_at_price: nil).where('compare_at_price > price')
  end
end
```

### Simple Content Type (Minimal Config)

```ruby
# app/content_types/team_member_type.rb
class TeamMemberType < Brawo::ContentType
  configure do |c|
    c.name = "Team Member"
    c.slug = "team"
  end
  
  routes do
    archive "/team"
    single "/team/:slug"
  end
  
  fields do
    field :name, :string, required: true
    field :role, :string, required: true
    field :bio, :text
    field :photo, :image
    field :email, :string
    field :linkedin_url, :string
    field :twitter_handle, :string
    field :display_order, :integer, default: 0
  end
  
  default_scope { order(display_order: :asc) }
  
  def social_links
    {
      linkedin: linkedin_url,
      twitter: twitter_url
    }.compact
  end
  
  def twitter_url
    return nil unless twitter_handle.present?
    "https://twitter.com/#{twitter_handle.delete_prefix('@')}"
  end
end
```

---

## Part 2: How Brawo Gem Works Behind the Scenes

### Content Type Registration (Automatic)

```ruby
# lib/brawo/engine.rb
module Brawo
  class Engine < ::Rails::Engine
    isolate_namespace Brawo
    
    initializer "brawo.load_content_types" do
      # Auto-load all content types from app/content_types
      Dir[Rails.root.join('app/content_types/**/*_type.rb')].each do |file|
        require file
      end
    end
    
    initializer "brawo.register_content_types" do
      # Register each content type and trigger table/route generation
      Brawo::ContentType.descendants.each do |content_type_class|
        Brawo::Registry.register(content_type_class)
      end
    end
  end
end
```

### Base Content Type Class (in Gem)

```ruby
# lib/brawo/content_type.rb
module Brawo
  class ContentType < ActiveRecord::Base
    self.abstract_class = true
    
    class << self
      attr_reader :config, :field_definitions, :route_config
      
      def configure(&block)
        @config ||= Configuration.new
        block.call(@config) if block_given?
        @config
      end
      
      def routes(&block)
        @route_config ||= RouteConfiguration.new
        block.call(@route_config) if block_given?
        @route_config
      end
      
      def fields(&block)
        @field_definitions ||= []
        FieldDefinitionDSL.new(@field_definitions).instance_eval(&block)
        @field_definitions
      end
      
      def inherited(subclass)
        super
        # Trigger table generation when subclass is defined
        Brawo::TableManager.ensure_table_exists(subclass)
        Brawo::RouteManager.register_routes(subclass)
      end
      
      # Common scopes available to all content types
      scope :published, -> { where(status: 'published').where('published_at <= ?', Time.current) }
      scope :draft, -> { where(status: 'draft') }
      scope :scheduled, -> { where(status: 'published').where('published_at > ?', Time.current) }
    end
    
    # Instance methods available to all content types
    def published?
      status == 'published' && published_at.present? && published_at <= Time.current
    end
    
    def url
      self.class.route_config.single_path(self)
    end
  end
end
```

### Table Manager (in Gem - Hidden from User)

```ruby
# lib/brawo/table_manager.rb
module Brawo
  class TableManager
    def self.ensure_table_exists(content_type_class)
      table_name = content_type_class.table_name
      
      return if ActiveRecord::Base.connection.table_exists?(table_name)
      
      # Generate migration in memory and execute
      ActiveRecord::Migration.create_table table_name do |t|
        # Base CMS fields (always present)
        t.string :slug, null: false, index: { unique: true }
        t.string :status, default: 'draft'
        t.datetime :published_at
        t.references :author, foreign_key: { to_table: :users }
        
        # Custom fields from content type definition
        content_type_class.field_definitions.each do |field_def|
          add_field_column(t, field_def)
        end
        
        t.timestamps
      end
      
      # Create model class dynamically
      create_active_record_model(content_type_class)
    end
    
    private
    
    def self.add_field_column(table, field_def)
      case field_def.type
      when :string then table.string field_def.name
      when :text then table.text field_def.name
      when :integer then table.integer field_def.name
      when :decimal then table.decimal field_def.name, precision: field_def.options[:precision], scale: field_def.options[:scale]
      when :boolean then table.boolean field_def.name, default: field_def.options[:default]
      when :datetime then table.datetime field_def.name
      when :date then table.date field_def.name
      when :json then table.json field_def.name
      when :array then table.string field_def.name, array: true, default: []
      when :image then table.string field_def.name # ActiveStorage attachment
      when :rich_text then table.text field_def.name # ActionText
      # Associations handled separately
      when :belongs_to then table.references field_def.name, foreign_key: field_def.options[:foreign_key]
      end
    end
    
    def self.create_active_record_model(content_type_class)
      # Set the table name
      content_type_class.table_name = content_type_class.config.slug.pluralize
      
      # Add ActiveStorage/ActionText if needed
      content_type_class.field_definitions.each do |field_def|
        case field_def.type
        when :image
          content_type_class.has_one_attached field_def.name
        when :images
          content_type_class.has_many_attached field_def.name
        when :rich_text
          content_type_class.has_rich_text field_def.name
        end
      end
    end
  end
end
```

### Route Manager (in Gem - Hidden from User)

```ruby
# lib/brawo/route_manager.rb
module Brawo
  class RouteManager
    def self.register_routes(content_type_class)
      route_config = content_type_class.route_config
      config = content_type_class.config
      
      Rails.application.routes.draw do
        # Archive route
        if route_config.archive_path
          get route_config.archive_path, 
              to: "brawo/content_entries#index",
              defaults: { content_type: config.slug },
              as: "#{config.slug}_archive"
        end
        
        # Single entry route
        if route_config.single_path_pattern
          get route_config.single_path_pattern,
              to: "brawo/content_entries#show",
              defaults: { content_type: config.slug },
              as: config.slug.singularize
        end
      end
    end
  end
end
```

---

## Part 3: Usage in Host Application

### Creating Content Types

```ruby
# Users just define content type classes
# Everything else happens automatically

# app/content_types/faq_type.rb
class FaqType < Brawo::ContentType
  configure do |c|
    c.name = "FAQ"
    c.slug = "faqs"
  end
  
  routes do
    archive "/help/faqs"
    # No single view needed for FAQs
  end
  
  fields do
    field :question, :string, required: true
    field :answer, :text, required: true
    field :category, :select, choices: ['General', 'Billing', 'Technical']
    field :display_order, :integer, default: 0
  end
  
  scope :by_category, ->(cat) { where(category: cat) }
  default_scope { order(display_order: :asc) }
end
```

### Using Content Types

```ruby
# In controllers
class BlogController < ApplicationController
  def index
    @posts = BlogPostType.published.featured.recent
  end
  
  def show
    @post = BlogPostType.published.find_by!(slug: params[:slug])
    @related = @post.related_posts
  end
end

# In views
<% @posts.each do |post| %>
  <article>
    <h2><%= post.title %></h2>
    <p><%= post.excerpt %></p>
    <span><%= post.reading_time_text %></span>
    <%= link_to "Read more", post.url %>
  </article>
<% end %>

# In services
class ProductSearch
  def self.perform(query)
    ProductType.where("name ILIKE ?", "%#{query}%")
               .or(ProductType.where("description ILIKE ?", "%#{query}%"))
               .in_stock
  end
end
```

### Custom Controllers (Optional)

```ruby
# app/controllers/content_types/blog_posts_controller.rb
class ContentTypes::BlogPostsController < Brawo::ContentEntriesController
  # Inherits from gem's base controller
  # Override only what you need
  
  def index
    @posts = BlogPostType.published.by_category(params[:category]) if params[:category]
    @posts ||= BlogPostType.published.recent
  end
  
  def show
    super # Use gem's default behavior
    @related_posts = @entry.related_posts
  end
end
```

---

## Part 4: Key Features

### What Users See
✅ One file per content type with everything inside
✅ Clean, Rails-like DSL
✅ Full ActiveRecord functionality
✅ Custom methods and logic
✅ Standard Rails patterns

### What Users Don't See
🔒 Migration files
🔒 Route definitions in routes.rb
🔒 Model boilerplate
🔒 Table schemas
🔒 Gem internals

### Automatic Behaviors
⚡ Tables created on app boot (if missing)
⚡ Routes registered automatically
⚡ Slug generation
⚡ Status management (draft/published/scheduled)
⚡ Timestamp handling
⚡ ActiveStorage integration
⚡ ActionText integration

---

## Part 5: Implementation Priorities

### Phase 1: Core Pattern
1. Create base `Brawo::ContentType` class with DSL
2. Implement TableManager for dynamic table creation
3. Implement RouteManager for automatic routing
4. Create field definition system
5. Build registration system on boot

### Phase 2: Field Types
1. Basic types (string, text, integer, boolean, etc.)
2. Rich content (rich_text, wysiwyg)
3. Media (image, images, file)
4. Relationships (belongs_to, has_many)
5. Custom field type registration

### Phase 3: Admin Interface
1. Auto-generated admin for each content type
2. Form builder based on field definitions
3. List views with filtering/sorting
4. Bulk actions
5. Preview functionality

### Phase 4: Advanced Features
1. Versioning/revisions
2. Multi-language support
3. Custom field validation DSL
4. Computed fields
5. Field dependencies

---

## Success Criteria

✅ Single file contains entire content type definition
✅ No migrations visible to user
✅ No routes.rb modifications needed
✅ Tables auto-generate on boot
✅ Routes auto-register on boot
✅ Full ActiveRecord API available
✅ Custom methods work naturally
✅ Can extend without gem modifications
✅ Zero magic - everything is Ruby classes
✅ Performance equals hand-written Rails