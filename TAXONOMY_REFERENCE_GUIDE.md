# Taxonomy Reference Field Type

## Overview

The `:taxonomy` field type allows content types and taxonomies to reference taxonomy entries. When you use this field type, the admin interface automatically generates a select dropdown populated with all entries from the specified taxonomy type.

## Usage

### In Content Types

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { 
        name: :category_id, 
        type: :taxonomy, 
        taxonomy_type: :category, 
        label: 'Category',
        help_text: 'Select a category for this article',
        required: false  # Optional: set to true to remove blank option
      }
    ]
end
```

### In Taxonomies (for hierarchical taxonomies)

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { 
        name: :parent_id, 
        type: :taxonomy, 
        taxonomy_type: :category, 
        label: 'Parent Category',
        help_text: 'Optional parent category for hierarchy'
      }
    ]
end
```

## Field Configuration Options

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `name` | Symbol | Yes | Field identifier (e.g., `:category_id`) |
| `type` | Symbol | Yes | Must be `:taxonomy` |
| `taxonomy_type` | Symbol | Yes | The taxonomy type to reference (e.g., `:category`) |
| `label` | String | No | Display label (defaults to titleized name) |
| `help_text` | String | No | Help text shown below the field |
| `required` | Boolean | No | If true, removes the blank option from select |
| `options` | Hash | No | Additional HTML options for the select field |

## How It Works

### Form Rendering

When a field with `type: :taxonomy` is rendered in a form:

1. The helper looks up the taxonomy type from `BrawoCms.taxonomy_types`
2. Queries all entries of that taxonomy type, ordered by name
3. Generates a select dropdown with options: `[entry.name, entry.id]`
4. Includes a blank option by default (unless `required: true`)

Example HTML output:
```html
<select name="content[category_id]" class="form-select">
  <option value="">Select Category</option>
  <option value="1">Technology</option>
  <option value="2">Business</option>
  <option value="3">Lifestyle</option>
</select>
```

### Value Display

When displaying the field value in show/index views:

1. The helper retrieves the stored ID value
2. Looks up the taxonomy entry by ID
3. Displays the taxonomy entry's name
4. Shows `-` if no value or entry not found

Example:
```ruby
# Stored value: "1"
# Displayed as: "Technology"
```

## Complete Example

### Step 1: Define Taxonomy

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

### Step 2: Create Taxonomy Entries

Via admin interface or console:
```ruby
Category.create(name: "Technology", color: "#3b82f6")
Category.create(name: "Business", color: "#10b981")
Category.create(name: "Lifestyle", color: "#f59e0b")
```

### Step 3: Reference in Content Type

```ruby
# app/models/article.rb
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :title, type: :string, label: 'Title' },
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' }
    ]
end
```

### Step 4: Use in Application

```ruby
# Create article with category
article = Article.create(
  title: "New Tech Trends",
  category_id: Category.find_by(name: "Technology").id
)

# Access the category
category_id = article.category_id
category = Category.find(category_id)
puts category.name # => "Technology"
```

## Advanced Examples

### Multiple Taxonomy References

```ruby
class Article < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :article,
    label: 'Article',
    fields: [
      { name: :category_id, type: :taxonomy, taxonomy_type: :category, label: 'Category' },
      { name: :author_id, type: :taxonomy, taxonomy_type: :author, label: 'Author' },
      { name: :primary_tag_id, type: :taxonomy, taxonomy_type: :tag, label: 'Primary Tag' }
    ]
end
```

### Hierarchical Taxonomies

```ruby
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable

  taxonomy_type :category,
    label: 'Category',
    fields: [
      { 
        name: :parent_id, 
        type: :taxonomy, 
        taxonomy_type: :category, 
        label: 'Parent Category',
        help_text: 'Leave blank for top-level category'
      }
    ]

  # Add helper methods
  def parent
    Category.find_by(id: parent_id) if parent_id.present?
  end

  def children
    Category.where("fields->>'parent_id' = ?", id.to_s)
  end
end
```

### Required Field

```ruby
{ 
  name: :category_id, 
  type: :taxonomy, 
  taxonomy_type: :category, 
  label: 'Category',
  required: true  # No blank option
}
```

## Helper Methods Reference

### `render_taxonomy_select(form, field_name, field, field_options)`

Renders a select dropdown for taxonomy references.

**Parameters:**
- `form` - The form builder object
- `field_name` - The field name (symbol or string)
- `field` - Field configuration hash
- `field_options` - Additional HTML options

**Returns:** HTML select element

### `display_taxonomy_value(value, field)`

Displays the name of a referenced taxonomy entry.

**Parameters:**
- `value` - The stored taxonomy ID
- `field` - Field configuration hash

**Returns:** Taxonomy entry name or '-' if not found

## Best Practices

1. **Naming Convention**: Use `_id` suffix for taxonomy reference fields (e.g., `category_id`, `author_id`)

2. **Create Taxonomies First**: Ensure taxonomy entries exist before using them in content

3. **Handle Missing Values**: The helpers gracefully handle missing or deleted taxonomy entries

4. **Performance**: Taxonomy entries are loaded once per form, not per option

5. **Validation**: Add custom validations if needed:
   ```ruby
   validates :category_id, presence: true
   validate :category_exists
   
   private
   
   def category_exists
     if category_id.present? && !Category.exists?(category_id)
       errors.add(:category_id, "selected category does not exist")
     end
   end
   ```

## Troubleshooting

### Dropdown is Empty
- Ensure the taxonomy type is registered: `BrawoCms.taxonomy_types[:category]`
- Check that taxonomy entries exist: `Category.count > 0`
- Verify the `taxonomy_type` matches the registered name

### Shows ID Instead of Name
- Check that the field type is `:taxonomy` (not `:select` or `:string`)
- Ensure `taxonomy_type` option is specified
- Verify the taxonomy class is properly defined

### Blank Option Always Shows
- Set `required: true` in the field configuration to hide the blank option

## Migration from Select Fields

If you previously used `:select` fields with hardcoded choices:

**Before:**
```ruby
{ 
  name: :category, 
  type: :select, 
  label: 'Category', 
  choices: [['Technology', 'tech'], ['Business', 'business']] 
}
```

**After:**
```ruby
# 1. Create taxonomy type
class Category < BrawoCms::Taxonomy
  include BrawoCms::TaxonomyTypeable
  taxonomy_type :category, label: 'Category', fields: []
end

# 2. Migrate data (create taxonomy entries)
Category.create(name: "Technology", slug: "tech")
Category.create(name: "Business", slug: "business")

# 3. Update field definition
{ 
  name: :category_id,  # Note: renamed to category_id
  type: :taxonomy, 
  taxonomy_type: :category,
  label: 'Category'
}

# 4. Update existing content (if needed)
Article.all.each do |article|
  if article.category == 'tech'
    article.category_id = Category.find_by(slug: 'tech').id
    article.save
  end
end
```

## Future Enhancements

Potential improvements for taxonomy references:

- **Multi-select**: Support for selecting multiple taxonomy entries
- **AJAX Search**: For taxonomies with many entries
- **Inline Creation**: Create new taxonomy entries from content form
- **Relationship Methods**: Automatic `belongs_to` style methods
- **Eager Loading**: Optimize queries when displaying many items

