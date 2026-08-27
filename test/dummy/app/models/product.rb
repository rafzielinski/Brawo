class Product < BrawoCms::Content
  include BrawoCms::ContentTypeable

  content_type :product,
    label: 'Product',
    fields: [
      { 
        name: :price, 
        type: :number, 
        label: 'Price', 
        help_text: 'Product price in USD' 
      },
      { 
        name: :sku,
        type: :string, 
        label: 'SKU', 
        help_text: 'Stock keeping unit' 
      },
      { 
        name: :stock_quantity, 
        type: :integer, 
        label: 'Stock Quantity' 
      },
      { name: :product_description, type: :textarea, label: 'Description' },
      { name: :featured_product, type: :boolean, label: 'Featured' },
      { name: :availability, type: :select, label: 'Availability', choices: [['In Stock', 'in_stock'], ['Out of Stock', 'out_of_stock'], ['Pre-order', 'preorder']] },
      {
        name: :accent_color,
        type: :color,
        label: 'Accent color',
        swatches: ['#48BB78', '#4299E1'],
        wrapper: {
          width: '50'
        } 
      },
      { name: :badge_icon, 
        type: :icon, 
        label: 'Badge icon', 
        help_text: 'Icon for the badge',
        wrapper: {
          width: '50'
        } 
      },
      { name: :product_url, 
        type: :url, 
        label: 'Product URL', 
        help_text: 'URL for the product',
        wrapper: {
          width: '50'
        } 
      },
      { name: :contact_email, 
        type: :email, 
        label: 'Contact email', 
        help_text: 'Email for the contact',
        wrapper: {
          width: '50'
        } 
      },
      {
        name: :featured_image,
        type: :media,
        label: 'Featured image',
        accept: 'image/*',
        wrapper: {
          width: '50'
        }
      }
    ]
end
