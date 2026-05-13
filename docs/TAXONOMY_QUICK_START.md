# Taxonomy Reference Quick Start

## Visual Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     TAXONOMY SYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌───────────────┐        ┌───────────────┐                │
│  │   Category    │        │    Author     │                │
│  │  (Taxonomy)   │        │  (Taxonomy)   │                │
│  ├───────────────┤        ├───────────────┤                │
│  │ - Technology  │        │ - John Doe    │                │
│  │ - Business    │        │ - Jane Smith  │                │
│  │ - Lifestyle   │        │ - Bob Jones   │                │
│  └───────┬───────┘        └───────┬───────┘                │
│          │                        │                         │
│          │  Referenced via        │                         │
│          │  :taxonomy field       │                         │
│          │                        │                         │
│  ┌───────┴────────────────────────┴───────┐                │
│  │         Article (Content)              │                │
│  ├────────────────────────────────────────┤                │
│  │ title: "New Tech Trends"               │                │
│  │ category_id: 1  ──> "Technology"       │                │
│  │ author_id: 1    ──> "John Doe"         │                │
│  └────────────────────────────────────────┘                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Quick Setup (3 Steps)

### 1️⃣ Define Taxonomy

```ruby
# app/models/category.rb
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { name: :color, type: :string, label: 'Color' }
    ]
end
```

### 2️⃣ Add Entries (via Admin or Console)

```ruby
Category.create(name: "Technology", color: "#3b82f6")
Category.create(name: "Business", color: "#10b981")
Category.create(name: "Lifestyle", color: "#f59e0b")
```

### 3️⃣ Reference in Content

```ruby
# app/models/article.rb
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { 
        name: :category_id,           # Field name (use _id suffix)
        type: :taxonomy,              # Field type
        taxonomy_type: :category,     # Which taxonomy to reference
        label: 'Category'             # Display label
      }
    ]
end
```

## What Happens Automatically

### In Admin Forms ✨

When creating/editing an Article, you'll see:

```
┌────────────────────────────────────┐
│ Category                           │
│ ┌────────────────────────────────┐ │
│ │ Select Category              ▼ │ │
│ └────────────────────────────────┘ │
│   Options:                         │
│   - (blank)                        │
│   - Technology                     │
│   - Business                       │
│   - Lifestyle                      │
└────────────────────────────────────┘
```

### In Admin Display 📊

When viewing an Article:

```
┌────────────────────────────────────┐
│ Category: Technology               │
│                                    │
│ (not "1" - shows the name!)        │
└────────────────────────────────────┘
```

## Field Configuration Options

```ruby
{ 
  name: :category_id,              # Required: field identifier
  type: :taxonomy,                 # Required: must be :taxonomy
  taxonomy_type: :category,        # Required: which taxonomy
  label: 'Category',               # Optional: display label
  help_text: 'Select category',    # Optional: help text
  required: true                   # Optional: remove blank option
}
```

## Usage in Your Application

```ruby
# Find article
article = Article.find(1)

# Get the taxonomy ID
category_id = article.category_id
# => 1

# Look up the taxonomy
category = Category.find(category_id)
# => #<Category id: 1, name: "Technology", ...>

# Access taxonomy name
category.name
# => "Technology"

# Access custom fields
category.color
# => "#3b82f6"

# Display in views
"#{article.title} in #{category.name}"
# => "New Tech Trends in Technology"
```

## Multiple References

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' },
      { name: :author_id, type: :taxonomy, taxonomy_type: :author, label: 'Author' },
      { name: :tag_id, type: :taxonomy, taxonomy_type: :tag, label: 'Primary Tag' }
    ]
end
```

Each field gets its own dropdown with the appropriate taxonomy entries!

## Hierarchical Taxonomies

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { 
        name: :parent_id, 
        type: :taxonomy, 
        taxonomy_type: :category,  # References itself!
        label: 'Parent Category' 
      }
    ]

  # Helper methods
  def parent
    Category.find_by(id: parent_id) if parent_id
  end

  def children
    Category.where("fields->>'parent_id' = ?", id.to_s)
  end
end
```

Now categories can have parents:
```
Technology
  ├─ Software
  ├─ Hardware
  └─ AI/ML

Business
  ├─ Finance
  └─ Marketing
```

## Common Patterns

### Required Category

```ruby
{ 
  name: :category_id, 
  type: :taxonomy, 
  taxonomy_type: :category, 
  label: 'Category',
  required: true  # No blank option
}
```

### With Validation

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' }
    ]

  validates :category_id, presence: true
  validate :category_exists

  private

  def category_exists
    if category_id.present? && !Category.exists?(category_id)
      errors.add(:category_id, "must exist")
    end
  end
end
```

### Helper Method in Content

```ruby
class Article < BrawoCms::Content
  # ... content_type definition ...

  def category
    @category ||= Category.find_by(id: category_id)
  end

  def category_name
    category&.name || 'Uncategorized'
  end
end
```

Then in views:
```erb
<%= @article.category_name %>
```

## Comparison with Select Fields

### ❌ Old Way: Hardcoded Select

```ruby
{ 
  name: :category, 
  type: :select, 
  choices: [['Tech', 'tech'], ['Business', 'biz']] 
}
```

**Problems:**
- Hardcoded in code
- Need deployment to change
- No metadata support
- Just stores arbitrary strings

### ✅ New Way: Taxonomy Reference

```ruby
{ 
  name: :category_id, 
  type: :taxonomy, 
  taxonomy_type: :category 
}
```

**Benefits:**
- Managed via admin
- Change instantly
- Rich metadata (color, icon, etc.)
- Stores proper IDs
- Reusable across content

## Troubleshooting

### Dropdown is empty?
→ Create some taxonomy entries first!
```ruby
Category.create(name: "My Category")
```

### Shows ID instead of name?
→ Ensure field `type: :taxonomy` (not `:select` or `:string`)

### Error: taxonomy_type not found?
→ Check the taxonomy is registered:
```ruby
BrawoCms.taxonomy_types[:category]
```

## Next Steps

📚 **Read Full Documentation:**
- [TAXONOMY_GUIDE.md](TAXONOMY_GUIDE.md) - Complete taxonomy system guide
- [TAXONOMY_REFERENCE_GUIDE.md](TAXONOMY_REFERENCE_GUIDE.md) - Detailed reference documentation

🚀 **Try It:**
1. Start your Rails server
2. Visit `/admin`
3. Create some taxonomies
4. Add taxonomy references to your content types
5. See the magic happen! ✨

